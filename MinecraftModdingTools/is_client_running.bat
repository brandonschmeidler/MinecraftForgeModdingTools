set PID=%1
tasklist /fi "PID eq %PID%" /fi "STATUS eq RUNNING" /fo list