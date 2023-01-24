user_prompt = "Type add to add, show to show, or exit to exit: "
user_list = []
x =1 

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
        case "exit":
            print("Thanks for using my program.")
            break
        case _:
            print("Incorrect command.")