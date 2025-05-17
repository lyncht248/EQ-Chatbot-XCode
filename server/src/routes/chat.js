import { Router } from 'express';
import { sendToClaude } from '../services/llm.js';
import { supabase } from '../utils/supabase.js';

const router = Router();

/**
 * Route for sending a message to the chatbot and receiving a response
 * Expects: { userId: string, messages: array of {role, content} }
 * Returns: { reply: string }
 */
router.post('/', async (req, res) => {
    try {
        const { userId, messages } = req.body;

        if (!userId || !messages || !Array.isArray(messages) || messages.length === 0) {
            return res.status(400).json({ error: 'Invalid request. userId and messages array required.' });
        }

        // Get the user's most recent message
        const userMessage = messages[messages.length - 1];

        // Call Claude API to get response
        const assistantReply = await sendToClaude(messages);

        // Store both user & assistant messages in Supabase
        try {
            await supabase.from('chats').insert([
                { user_id: userId, role: 'user', content: userMessage.content },
                { user_id: userId, role: 'assistant', content: assistantReply }
            ]);
        } catch (dbError) {
            // Log error but don't fail the request
            console.error('Error storing messages in database:', dbError);
        }

        // Return the assistant's reply to the client
        res.json({ reply: assistantReply });
    } catch (error) {
        console.error('Error in chat endpoint:', error);
        res.status(500).json({ error: 'Failed to process chat request' });
    }
});

/**
 * Route for getting chat history for a user
 */
router.get('/history/:userId', async (req, res) => {
    try {
        const { userId } = req.params;

        const { data, error } = await supabase
            .from('chats')
            .select('*')
            .eq('user_id', userId)
            .order('created_at', { ascending: true });

        if (error) throw error;

        res.json({ history: data });
    } catch (error) {
        console.error('Error fetching chat history:', error);
        res.status(500).json({ error: 'Failed to fetch chat history' });
    }
});

export default router;
