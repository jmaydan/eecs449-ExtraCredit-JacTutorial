"""AI task plan item component."""

def:pub BreakdownItem(item: dict) -> any {
    return
        <div className="plan-item">
            <div className="plan-info">
                <span className="plan-title">{item.title}</span>
                <div className="plan-meta">
                    {(
                        <span className={("priority-badge priority-" + item.priority)}>
                            {item.priority}
                        </span>
                    ) if item.priority else None}
                    {(
                        <span className="estimate-badge">
                            {item.estimate_mins} min
                        </span>
                    ) if item.estimate_mins and item.estimate_mins > 0 else None}
                    {(
                        <span className="category-badge">{item.category}</span>
                    ) if item.category and item.category != "other" else None}
                </div>
            </div>
        </div>;
}
