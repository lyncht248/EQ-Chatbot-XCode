## MVP Chatbot App - Step-by-Step Plan

This document outlines a detailed plan to build an iOS MVP chatbot using SwiftUI, Node.js/Express, Supabase, Anthropic Claude 3.5 Haiku, Vercel, and GitHub.

---

### 🎯 Goal

Create a basic iPhone app with a chat UI that sends user messages to a backend, relays them to Claude 3.5 Haiku via API, and displays humanlike responses.
Later this chatbot will need to call functions that interact with iOS Screentime and DeviceActivity APIs, but this is not part of this MVP.

---

## 1. Prerequisites

* **Accounts & Tools**:

  * Supabase account & project
  * Anthropic API key for Claude 3.5 Haiku
  * Vercel account
  * GitHub repository
  * Xcode installed
  * Node.js + npm/yarn
  * Familiarity with SwiftUI, Express, and Supabase

* **Existing Setup**:

  * Initialized Xcode SwiftUI project
  * Initialized Git repository and linked to GitHub

---

## 2. Project Structure

```text
├── client-ios/          # SwiftUI Xcode workspace
│   └── ChatApp.xcodeproj
│   └── ChatApp/        # Swift source files
│       └── Views/
│       └── ViewModels/
│       └── Services/
│
├── server/             # Node.js + Express backend
│   └── src/
│       └── index.js
│       └── routes/chat.js
│       └── services/   # LLM integration code
│       └── utils/      # helper modules
│   └── package.json
│
└── README.md
```

---

## 3. Step-by-Step Implementation

### 3.1. Supabase Setup

1. **Create Project**: In Supabase dashboard, create a new project.
2. **Auth**: Enable Email + OAuth (Apple). Copy `SUPABASE_URL` and `SUPABASE_ANON_KEY`.
3. **Database**: Create table `chats` with columns:

   * `id` (UUID, primary key)
   * `user_id` (UUID, foreign to auth.users)
   * `role` (text: `user` or `assistant`)
   * `content` (text)
   * `created_at` (timestamp, default now())
4. **RLS Policies**: Enable Row-Level Security on `chats` and add policies to allow each user to read/write their own rows.

### 3.2. Backend: Node.js + Express

1. **Initialize**: `npm init -y` & install dependencies:

   ```bash
   npm install express cors dotenv @supabase/supabase-js axios
   ```
2. **Environment**: Create `.env` with:

   ```ini
   PORT=3000
   SUPABASE_URL=your_supabase_url
   SUPABASE_SERVICE_KEY=your_supabase_service_role_key
   ANTHROPIC_API_KEY=your_anthropic_key
   ```
3. **Express Server** (`src/index.js`):

   ```js
   import express from 'express';
   import cors from 'cors';
   import chatRouter from './routes/chat.js';

   const app = express();
   app.use(cors(), express.json());
   app.use('/chat', chatRouter);
   app.listen(process.env.PORT, () => console.log(`Server up on ${process.env.PORT}`));
   ```
4. **Chat Route** (`src/routes/chat.js`):

   ```js
   import { Router } from 'express';
   import { sendToClaude } from '../services/llm.js';
   import { supabase } from '../utils/supabase.js';

   const router = Router();

   router.post('/', async (req, res) => {
     const { userId, messages } = req.body;
     // Call LLM
     const assistantReply = await sendToClaude(messages);
     // Store both user & assistant messages
     await supabase.from('chats').insert([
       { user_id: userId, role: 'user', content: messages.slice(-1)[0].content },
       { user_id: userId, role: 'assistant', content: assistantReply }
     ]);
     res.json({ reply: assistantReply });
   });

   export default router;
   ```
5. **LLM Service** (`src/services/llm.js`):

   ```js
   import axios from 'axios';

   export async function sendToClaude(messages) {
     const response = await axios.post(
       'https://api.anthropic.com/v1/chat/completions',
       { model: 'claude-3.5-haiku', messages },
       { headers: { 'x-api-key': process.env.ANTHROPIC_API_KEY } }
     );
     return response.data.completion;
   }
   ```
6. **Supabase Client** (`src/utils/supabase.js`):

   ```js
   import { createClient } from '@supabase/supabase-js';
   export const supabase = createClient(
     process.env.SUPABASE_URL,
     process.env.SUPABASE_SERVICE_KEY
   );
   ```

### 3.3. Deploy Backend on Vercel

1. **Vercel CLI**: `npm i -g vercel` & login.
2. **Configure**: In project root, `vercel` and link to GitHub repo.
3. **Set Env Vars**: In Vercel Dashboard, add `SUPABASE_URL`, `SUPABASE_SERVICE_KEY`, `ANTHROPIC_API_KEY`, `PORT`.
4. **Deploy**: `vercel --prod` → note your endpoint URL.

### 3.4. iOS Client: SwiftUI Setup

1. **Project Settings**: Add Swift Package for `Supabase` (Client.swift) and `Alamofire` (optional) or use `URLSession`.
2. **Auth**: Use Supabase Auth via REST or Swift SDK. On launch, prompt sign in.
3. **Models & ViewModels**:

   * `Message` struct (`id`, `role`, `content`, `timestamp`).
   * `ChatViewModel`: holds `[Message]`, `send(_:)` method.
4. **Networking** (`ChatService.swift`):

   ```swift
   class ChatService {
     let baseURL = "https://<your-vercel-endpoint>";
     func send(messages: [Message], userId: String) async throws -> String {
       let url = URL(string: "\(baseURL)/chat")!
       var req = URLRequest(url: url)
       req.httpMethod = "POST"
       req.addValue("application/json", forHTTPHeaderField: "Content-Type")
       let body = ["userId": userId, "messages": messages]
       req.httpBody = try JSONEncoder().encode(body)
       let (data, _) = try await URLSession.shared.data(for: req)
       let resp = try JSONDecoder().decode([String: String].self, from: data)
       return resp["reply"]!
     }
   }
   ```
5. **SwiftUI View** (`ChatView.swift`):

   * `ScrollView` of message bubbles.
   * `TextField` + `Send` button.
   * On send: append user message, call `ChatService.send`, append assistant reply.

### 3.5. Versioning & CI/CD

1. **GitHub**:

   * Protect `main` branch, require PR reviews.
   * Use `.github/workflows/ci.yml` to lint JS and run Swift tests.
2. **Vercel**:

   * Auto-deploy on `main` pushes.
   * Preview deployments on PRs.

---

## 4. Testing & Quality

* **Backend**: Jest + Supertest for API routes.
* **iOS**: XCTest for ViewModel logic; UI tests for chat flow.
* **Manual**: End-to-end confirm chat round-trip under 1s.

---

## 5. Next Steps

* Implement Apple ScreenTime / DeviceActivity integration in Swift.
* Add SSE/WebSocket for streaming LLM tokens.
* Build analytics dashboard (Supabase or external).
