todos = []
while True:
    user_action = input("Type add, show, edit, or exit: ")
    user_action = user_action.strip()

    match user_action:
        case 'add':
            todo = input("Enter a todo: ")
            todos.append(todo)
        case 'show':
            for index, item in enumerate(todos):
                print((index + 1), "-", item)
        case 'edit':
            number = int(input("Number of the todo to edit: "))
            number = number - 1
            new_todo = input("Enter the todo: ")
            todos[number] = new_todo
        case 'exit':
            break