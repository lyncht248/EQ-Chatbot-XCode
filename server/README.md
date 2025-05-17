# EQ Chatbot Backend

This is the backend for the EQ Chatbot iOS application, providing API endpoints for the chat functionality and integration with Claude 3.5 Haiku.

## Setup

1. Clone the repository
2. Install dependencies:
   ```bash
   cd server
   npm install
   ```
3. Copy the example environment file and fill in your own values:
   ```bash
   cp .env.example .env
   ```
4. Add your credentials to the `.env` file:
   - `SUPABASE_URL`: Your Supabase project URL
   - `SUPABASE_SERVICE_KEY`: Your Supabase service role key
   - `ANTHROPIC_API_KEY`: Your Anthropic API key

## Running Locally

Start the development server:
```bash
npm run dev
```

The server will be available at http://localhost:3000.

## API Endpoints

- `POST /chat`: Send a message to the chatbot
  - Request body: `{ userId: string, messages: array of {role, content} }`
  - Response: `{ reply: string }`

- `GET /chat/history/:userId`: Get chat history for a user
  - Response: `{ history: array of chat messages }`

## Deployment

This project is configured for deployment on Vercel:

```bash
vercel login
vercel
```

Make sure to set the environment variables in the Vercel dashboard.
