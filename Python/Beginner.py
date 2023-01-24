def print_name(name):
    print('Hello', (name))

firstname = input('Enter name: ')
lastname = input('Enter last name: ')
wholename = (firstname + ' ' + lastname + '.')
print_name(wholename)