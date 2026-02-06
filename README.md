# TaskFlow Todo App

Name: Jonathan Maydan  
UMID: [add your UMID]

A Jac client-side todo application with AI features (categorization, meal planner, and AI Task Studio).

## Standout Extra Credit Feature

**AI Task Studio**: Describe a big goal and the app generates a prioritized, time-estimated task plan. You can review the steps, see total estimated time, and add the full plan to your todo list with one click. Manual todos are also auto-prioritized and time-estimated by the AI.

## Project Structure

```
my-todo-app/
├── jac.toml              # Project configuration
├── main.jac              # Main application entry
├── components/           # Reusable components
│   └── Button.cl.jac     # Example Jac component
├── assets/               # Static assets (images, fonts, etc.)
└── build/                # Build output (generated)
```

## Getting Started

Start the development server:

```bash
jac start main.jac
```

## How The Feature Works

1. **Backend AI logic** (`main.jac`): `analyze_todo` assigns category, priority, and a time estimate for new todos, and `GenerateTaskBreakdown` uses the LLM to break a big goal into tasks with priorities and estimates.
2. **Frontend UI** (`frontend.cl.jac`, `frontend.impl.jac`): the AI Task Studio panel allows goal input, renders the plan, and adds items to the todo list.
3. **UI Components + Styling** (`components/BreakdownItem.cl.jac`, `components/TodoItem.cl.jac`, `styles.css`): renders each AI-planned task, shows priority/time badges, and styles the new panel and buttons.

## Relevant Files

- `main.jac`
- `frontend.cl.jac`
- `frontend.impl.jac`
- `components/BreakdownItem.cl.jac`
- `components/TodoItem.cl.jac`
- `styles.css`
