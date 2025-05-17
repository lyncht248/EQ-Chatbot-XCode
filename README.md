# EQ Chatbot

A human-like chatbot iOS app that communicates in a highly personable way, built with SwiftUI, Node.js/Express, and Anthropic's Claude.

## Project Overview

EQ Chatbot provides a conversational interface where users can chat with an AI assistant powered by Claude 3.5 Haiku. The app features a clean, intuitive design and focuses on human-like, personable interactions.

## Project Structure

The project is divided into two main components:

- **iOS Client** - SwiftUI app for iPhone
- **Backend** - Node.js + Express API that connects to Claude and Supabase

### iOS Client

The iOS client is built with SwiftUI and follows the MVVM (Model-View-ViewModel) architecture for clean separation of concerns:

```
EQ Chatbot XCode/
├── Models/
│   ├── Message.swift      # Chat message model
│   └── User.swift         # User model
├── Views/
│   ├── ChatView.swift     # Main chat interface
│   ├── MessageBubbleView.swift  # Individual message bubbles
│   ├── SettingsView.swift  # App settings
│   └── WelcomeView.swift  # Welcome/sign-in screen
├── ViewModels/
│   └── ChatViewModel.swift  # Business logic for chat
├── Services/
│   ├── APIClient.swift    # Backend API communication
│   └── AuthService.swift  # Authentication handling
└── EQ_Chatbot_XCodeApp.swift  # Main app entry point
```

### Backend

The backend is built with Node.js and Express, providing an API for the iOS client and handling communication with Claude and Supabase:

```
server/
├── src/
│   ├── routes/
│   │   └── chat.js       # Chat API endpoints
│   ├── services/
│   │   └── llm.js        # Claude API integration
│   ├── utils/
│   │   └── supabase.js   # Supabase client
│   └── index.js          # Main Express server
├── package.json          # Node.js dependencies
└── vercel.json           # Vercel deployment config
```

## Setup Instructions

### Prerequisites

- Xcode 14+ (for iOS development)
- Node.js 18+ (for backend development)
- Anthropic API key (for Claude)
- Supabase account & project

### Backend Setup

1. Navigate to the server directory:
   ```bash
   cd server
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Create a `.env` file with your API keys (see `.env.example` for format):
   ```
   PORT=3000
   SUPABASE_URL=your_supabase_url
   SUPABASE_SERVICE_KEY=your_supabase_service_role_key
   ANTHROPIC_API_KEY=your_anthropic_key
   ```

4. Start the development server:
   ```bash
   npm run dev
   ```

5. Deploy to Vercel (optional):
   ```bash
   vercel
   ```

### iOS Setup

1. Open the `EQ Chatbot XCode.xcodeproj` file in Xcode.

2. Update the `baseURL` in `APIClient.swift` with your deployed backend URL.

3. Build and run the app in Xcode.

## Database Setup

In your Supabase project, create a table with the following structure:

```sql
CREATE TABLE chats (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL,
  role TEXT NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add RLS policies
ALTER TABLE chats ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own chats"
  ON chats FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own chats"
  ON chats FOR INSERT
  WITH CHECK (auth.uid() = user_id);
```

## Future Enhancements

- Implement proper Supabase Auth for user authentication
- Add message streaming for more responsive chat experience
- Integrate iOS ScreenTime and DeviceActivity APIs
- Add more personalization options
- Implement offline support and message queuing

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
