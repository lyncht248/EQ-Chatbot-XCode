import axios from 'axios';
import dotenv from 'dotenv';

dotenv.config();

// API Key check
const apiKey = process.env.ANTHROPIC_API_KEY;
if (!apiKey) {
    console.error('Missing Anthropic API key. Please check your .env file.');
    process.exit(1);
}

/**
 * Sends a message to Claude and returns the response
 * @param {Array} messages - Array of message objects with format {role: string, content: string}
 * @returns {Promise<string>} - Claude's response text
 */
export async function sendToClaude(messages) {
    try {
        const response = await axios.post(
            'https://api.anthropic.com/v1/messages',
            {
                model: 'claude-3-haiku-20240307',
                messages: messages,
                max_tokens: 1000,
                temperature: 0.7,
            },
            {
                headers: {
                    'Content-Type': 'application/json',
                    'x-api-key': apiKey,
                    'anthropic-version': '2023-06-01'
                }
            }
        );

        return response.data.content[0].text;
    } catch (error) {
        console.error('Error calling Claude API:', error.response?.data || error.message);
        throw new Error('Failed to get response from Claude API');
    }
}
