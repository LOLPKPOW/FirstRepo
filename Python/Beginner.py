def print_name(name):
    print('Hello', (name))

firstname = input('Enter name: ')
lastname = input('Enter last name: ')
wholename = (firstname + ' ' + lastname + '.')
print_name(wholename)

length = (len(wholename) - 2)
print("The name is", length, "characters long.")