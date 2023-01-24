prompt = "Enter a value:"
count = 1
user_inputs = []

while count < 4:
    user_input = input(prompt)
    user_inputs.append(user_input.title())
    count = count + 1
    print(user_inputs)