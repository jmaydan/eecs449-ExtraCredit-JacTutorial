"""Todo item component."""

def:pub TodoItem(todo: dict, onToggle: any, onDelete: any) -> any {
    return
        <div className="todo-item">
            <input
                type="checkbox"
                checked={todo.completed}
                onChange={lambda -> None { onToggle(todo.id); }}
                className="todo-checkbox"
            />
            <span className={("todo-title-completed" if todo.completed else "todo-title")}>
                {todo.title}
            </span>
            <div className="todo-meta">
                {(
                    <span className={("priority-badge priority-" + todo.priority)}>
                        {todo.priority}
                    </span>
                ) if todo.priority else None}
                {(
                    <span className="estimate-badge">
                        {todo.estimate_mins} min
                    </span>
                ) if todo.estimate_mins and todo.estimate_mins > 0 else None}
                {(
                    <span className="category-badge">{todo.category}</span>
                ) if todo.category and todo.category != "other" else None}
            </div>
            <button
                onClick={lambda -> None { onDelete(todo.id); }}
                className="todo-delete-btn"
            >
                ×
            </button>
        </div>;
}
