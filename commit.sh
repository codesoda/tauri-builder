#!/bin/bash

# source .env to get the OPENAI_API_KEY
source "$(dirname "$0")/.env"

# 📝 Get only the diff of what has already been staged
git_diff_output=$(git diff --cached)

# 🛑 Check if there are any staged changes to commit
if [ -z "$git_diff_output" ]; then
  echo "⚠️  No staged changes detected. Aborting."
  exit 1
fi

# 🗜️ Limit the number of lines sent to AI to avoid overwhelming it
git_diff_output_limited=$(echo "$git_diff_output" | head -n 1000)

# 📦 Prepare the AI prompt for the chat model
messages=$(jq -n --arg diff "$git_diff_output_limited" '[
  {"role": "system", "content": "You are an AI assistant that helps generate git commit messages based on code changes."},
  {"role": "user", "content": ("Suggest an informative commit message by summarizing code changes from the shared command output. The commit message should follow the conventional commit format and provide meaningful context for future readers.\n\nChanges:\n" + $diff)}
]')

# 🚀 Send the request to OpenAI API using the correct chat endpoint
response=$(curl -s -X POST https://api.openai.com/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -d "$(jq -n \
        --argjson messages "$messages" \
        '{
          model: "gpt-4o-mini",
          messages: $messages,
          temperature: 0.5,
          max_tokens: 1000
        }'
)")

# 🔄 Extract the AI-generated commit message
commit_message=$(echo "$response" | jq -r '.choices[0].message.content' | sed 's/^ *//g')

# 🛑 Check if we got a valid commit message from the AI
if [ -z "$commit_message" ] || [[ "$commit_message" == "null" ]]; then
  echo "🚫 Failed to generate a commit message from OpenAI."
  echo "⚠️ API Response: $response"
  exit 1
fi

# 📋 Show the suggested commit message and ask for confirmation
echo "🤖 Suggested commit message:"
echo "$commit_message"
read -p "Do you want to use this message? (y/n) " choice

if [[ "$choice" != "y" ]]; then
  echo "🛑 Commit aborted by the user."
  exit 1
fi

# 🛑 Option to dry run
if [[ $1 == "--dry-run" ]]; then
  echo "✅ Dry run: Commit message generated, but no commit was made."
  exit 0
fi

# 🔐 Commit only staged changes with the AI-generated message
if ! git commit -m "$commit_message"; then
  echo "❌ Commit failed. Aborting."
  exit 1
fi

# 🎉 Success message
echo "✅ Committed with message: $commit_message"
