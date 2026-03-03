#!/bin/bash
# .bashrc.d/05-ssh.sh - Initialize SSH agent (run once per session)

# Only start SSH agent if not already running
if [ -z "$SSH_AGENT_PID" ]; then
    eval "$(ssh-agent -s)" > /dev/null
    ssh-add ~/.ssh/id_ed25519 2>/dev/null
fi
