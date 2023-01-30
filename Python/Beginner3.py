user_prompt = "Type add, show, edit or exit: "
user_list = []
x =1 

# user_list = [List1, List2, List3, List5]

while True:
    user_action = input(user_prompt)
    user_action = user_action.strip()
    match user_action:
        case "add":
            user_variable = input("Enter addition: ")
            user_list.append(user_variable)
        case "show" | "display":
            for item in user_list:
                print(item.title())
        case "edit":
            number = (int(input("Which # entry would you like to edit? ")) - 1)
            user_list[number] = input("Enter new entry: ")
        case "exit":
            print("Thanks for using my program.")
            break
        case _:
            print("Incorrect command.")