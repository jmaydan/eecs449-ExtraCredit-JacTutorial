"""TaskFlow - A multi-user todo app with AI meal planning and task studio."""

cl {
    import from frontend { app as ClientApp }

    def:pub app -> any {
        return
            <ClientApp />;
    }
}

import from byllm.lib { Model }
import from uuid { uuid4 }

glob llm = Model(model_name="gemini/gemini-3-flash-preview");

# --- AI Types ---

enum Category { WORK, PERSONAL, SHOPPING, HEALTH, OTHER }

enum Priority { HIGH, MEDIUM, LOW }

enum Unit { PIECE, LB, OZ, CUP, TBSP, TSP, CLOVE, BUNCH }

obj Ingredient {
    has name: str;
    has quantity: float;
    has unit: Unit;
    has cost: float;
    has carby: bool;
}

obj TodoMeta {
    has category: Category;
    has priority: Priority;
    has estimate_mins: int;
}

obj TaskBreakdownItem {
    has title: str;
    has category: Category;
    has priority: Priority;
    has estimate_mins: int;
}

sem Ingredient.cost = "Estimated cost in USD";
sem Ingredient.carby = "True if this ingredient is high in carbohydrates";
sem TodoMeta.estimate_mins = "Estimated minutes to complete, integer 5-240";
sem TodoMeta.priority = "Urgency based on impact and time sensitivity";
sem TodoMeta.category = "Best-fit category for this task";
sem TaskBreakdownItem.estimate_mins = "Estimated minutes to complete, integer 5-240";
sem TaskBreakdownItem.title = "Short actionable step";
sem TaskBreakdownItem.priority = "Urgency based on impact and time sensitivity";

"""Analyze a todo to assign category, priority, and time estimate."""
def analyze_todo(title: str) -> TodoMeta by llm();

"""Break a goal into actionable tasks with priority and time estimates."""
def breakdown_goal(goal: str) -> list[TaskBreakdownItem] by llm();

"""Generate a shopping list of ingredients needed for a described meal."""
def generate_ingredients(meal_description: str) -> list[Ingredient] by llm();

# --- Data Nodes ---

node Todo {
    has id: str,
        title: str,
        completed: bool = False,
        category: str = "other",
        priority: str = "medium",
        estimate_mins: int = 0;
}

node MealIngredient {
    has name: str,
        quantity: float,
        unit: str,
        cost: float,
        carby: bool;
}

# --- Todo Walkers ---

walker:priv AddTodo {
    has title: str;
    has category: str = "";
    has priority: str = "";
    has estimate_mins: int = 0;

    can create with `root entry {
        category = self.category;
        priority = self.priority;
        estimate = self.estimate_mins;
        if not category or not priority or estimate <= 0 {
            meta = analyze_todo(self.title);
            if not category {
                category = str(meta.category).split(".")[-1].lower();
            }
            if not priority {
                priority = str(meta.priority).split(".")[-1].lower();
            }
            if estimate <= 0 {
                estimate = meta.estimate_mins;
            }
        }
        if not category { category = "other"; }
        if not priority { priority = "medium"; }
        if estimate <= 0 { estimate = 30; }
        if category { category = category.lower(); }
        if priority { priority = priority.lower(); }
        new_todo = here ++> Todo(
            id=str(uuid4()),
            title=self.title,
            category=category,
            priority=priority,
            estimate_mins=estimate
        );
        report {
            "id": new_todo[0].id,
            "title": new_todo[0].title,
            "completed": new_todo[0].completed,
            "category": new_todo[0].category,
            "priority": new_todo[0].priority,
            "estimate_mins": new_todo[0].estimate_mins
        };
    }
}

walker:priv ListTodos {
    has todos: list = [];

    can collect with `root entry {
        visit [-->];
    }

    can gather with Todo entry {
        self.todos.append({
            "id": here.id,
            "title": here.title,
            "completed": here.completed,
            "category": here.category,
            "priority": here.priority,
            "estimate_mins": here.estimate_mins
        });
    }

    can report_all with `root exit {
        report self.todos;
    }
}

walker:priv ToggleTodo {
    has todo_id: str;

    can search with `root entry {
        visit [-->];
    }

    can toggle with Todo entry {
        if here.id == self.todo_id {
            here.completed = not here.completed;
            report {
                "id": here.id,
                "completed": here.completed
            };
        }
    }
}

walker:priv DeleteTodo {
    has todo_id: str;

    can search with `root entry {
        visit [-->];
    }

    can delete with Todo entry {
        if here.id == self.todo_id {
            del here;
            report {"deleted": self.todo_id};
        }
    }
}

# --- AI Task Studio Walkers ---

walker:priv GenerateTaskBreakdown {
    has goal: str;

    can generate with `root entry {
        tasks = breakdown_goal(self.goal);
        result: list = [];
        for task in tasks {
            result.append({
                "title": task.title,
                "category": str(task.category).split(".")[-1].lower(),
                "priority": str(task.priority).split(".")[-1].lower(),
                "estimate_mins": task.estimate_mins
            });
        }
        report result;
    }
}

# --- Meal Planner Walkers ---

walker:priv GenerateShoppingList {
    has meal_description: str;

    can generate with `root entry {
        # First clear old ingredients
        visit [-->];
        # Then generate new ones
        ingredients = generate_ingredients(self.meal_description);
        result: list = [];
        for ing in ingredients {
            ing_data = {
                "name": ing.name,
                "quantity": ing.quantity,
                "unit": str(ing.unit).split(".")[-1].lower(),
                "cost": ing.cost,
                "carby": ing.carby
            };
            here ++> MealIngredient(
                name=ing_data["name"],
                quantity=ing_data["quantity"],
                unit=ing_data["unit"],
                cost=ing_data["cost"],
                carby=ing_data["carby"]
            );
            result.append(ing_data);
        }
        report result;
    }

    can clear_old with MealIngredient entry {
        del here;
    }
}

walker:priv ListMealPlan {
    has ingredients: list = [];

    can collect with `root entry {
        visit [-->];
    }

    can gather with MealIngredient entry {
        self.ingredients.append({
            "name": here.name,
            "quantity": here.quantity,
            "unit": here.unit,
            "cost": here.cost,
            "carby": here.carby
        });
    }

    can report_all with `root exit {
        report self.ingredients;
    }
}

walker:priv ClearMealPlan {
    can collect with `root entry {
        visit [-->];
    }

    can clear with MealIngredient entry {
        del here;
        report {"cleared": True};
    }
}
