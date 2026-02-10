---
name: auto-debug-command
description: Automatically executes a shell command, monitors logs for errors, and iteratively applies fixes until successful. Use when a command requires self-healing execution.
---

# Auto-Debug Command Execution

This skill automates the process of executing a shell command, monitoring its output for errors, attempting to debug and fix identified issues, and re-running the command until it succeeds.

## Workflow

When this skill is activated with a shell command, follow these steps:

1.  **Execute Command (Detached Mode):**
    *   Run the provided `command` using `run_shell_command` in detached mode (`-d`) if applicable (e.g., `docker-compose up --build -d`). This prevents the command from blocking the agent's execution.
    *   If the command is not a long-running process and doesn't support detached mode, execute it directly and capture its output.

2.  **Monitor and Collect Logs:**
    *   Immediately after executing the command, use appropriate tools to collect logs. For Docker Compose, this means `docker-compose logs --no-log-prefix`. For other commands, analyze the direct output or relevant log files.

3.  **Analyze Logs for Errors:**
    *   Scan the collected logs for keywords indicating errors (e.g., `ERROR`, `Failed`, `Exception`, `cannot`, `not found`).
    *   Identify the most recent or critical error message and its context (e.g., file path, line number, class name).

4.  **Diagnose and Propose Fix (Internal Reasoning):**
    *   Based on the identified error, diagnose the root cause.
    *   Formulate a concrete plan to fix the error. This may involve:
        *   Modifying configuration files (`write_file` or `replace`).
        *   Renaming files (`run_shell_command mv`).
        *   Adjusting environment variables.
        *   Updating `Dockerfile` contents.
        *   Consulting internal knowledge (e.g., OpenIG configuration patterns).
    *   **Crucially:** If the fix involves code/config modification, ensure it adheres to project conventions and existing patterns.

5.  **Apply Fix:**
    *   Execute the necessary tool calls (e.g., `write_file`, `replace`, `run_shell_command`) to apply the proposed fix.

6.  **Clean Up (if necessary):**
    *   If the command involves Docker containers, always bring them down (`docker-compose down`) before attempting to re-run `docker-compose up --build -d` with a new configuration. This ensures a clean state.

7.  **Loop or Conclude:**
    *   Go back to **Step 1** (Execute Command) and repeat the cycle until the logs indicate successful completion of the initial command without critical errors.
    *   If a series of attempts (e.g., 3-5 iterations) fails to resolve the issue, or if the error seems unresolvable given current tools/context, report the unresolvable state and the last error to the user, seeking further guidance.

8.  **Report Success:** Once the command runs successfully and logs show no errors, report success to the user and present any relevant output or next steps (e.g., how to verify the environment).

## Usage

Activate this skill when a shell command needs to be executed with automated error detection and self-correction.

Example: `Use the auto-debug-command skill to run "docker-compose up --build"`