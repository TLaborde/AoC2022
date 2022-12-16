import functools


def read_input(path: str = './13.input.txt'):
    inputs = []
    with open(path) as filet:
        for line in filet.readlines():

            # strip the escaped characters and spaces
            line = line.rstrip()

            # check whether line is empty
            if not line:
                continue

            # parse the list contained in the line
            # recursive parser
            end, line = parse_list(line, 0)

            # append to the output
            inputs.append(line)
    return inputs


def parse_list(line: str, idx: int):

    # initialize empty list
    output = []

    # make a sanity check
    assert line[idx] == '[', 'Something is fishy.'
    idx += 1

    # go through the string
    while idx < len(line):

        # check whether we need to recurse deeper
        if line[idx] == '[':

            # recurse deeper and get list plus the nex index
            idx, rec_list = parse_list(line, idx)

            # append the result to our current list
            output.append(rec_list)

        # check whether we hit a number
        elif line[idx].isdigit():

            # go further with the idx
            end = idx
            while end < len(line) and line[end].isdigit():
                end += 1

            # get the number
            number = int(line[idx:end])

            # append the number
            output.append(number)

            # set the index
            idx = end

        # check whether we hit a comma and just increase the idx
        elif line[idx] == ',':
            idx += 1

        # check whether we hit a closing bracket
        elif line[idx] == ']':
            break

        # debugging raise
        else:
            print(idx, line[idx])
            raise NotImplementedError

    return idx+1, output


def list_comparison(smaller_list: list, bigger_list: list):

    # go through the elements recursively
    for ele1, ele2 in zip(smaller_list, bigger_list):

        # check the condition for both integers
        if isinstance(ele1, int) and isinstance(ele2, int):
            if ele1 < ele2:
                return -1
            elif ele1 > ele2:
                return 1

        # check if one of two is a list and transfer any element that is int
        elif isinstance(ele1, list) or isinstance(ele2, list):

            # check for integer elements
            if isinstance(ele1, int):
                ele1 = [ele1]
            if isinstance(ele2, int):
                ele2 = [ele2]

            # recurse deeper and transform element to list
            result = list_comparison(ele1, ele2)

            # check whether the result brought anything
            # otherwise we continue
            if result:
                return result

    # all elements seem to be equal, check for list length
    if len(smaller_list) < len(bigger_list):
        return -1
    elif len(smaller_list) > len(bigger_list):
        return 1
    else:
        return 0


def main1():
    result = 0

    # get the input lists
    inputs = read_input()

    # go through the lists and compare them
    for idx, (l1, l2) in enumerate(zip(inputs[:-1:2], inputs[1::2])):

        # make a comparison
        comp = list_comparison(l1, l2)
        if comp == -1:
            result += idx + 1
    print(f'The result for solution 1 is: {result}')


def custom_bisect(arr: list, target: list, comparator: callable):

    # make binary search on the array
    left = 0
    right = len(arr) - 1

    # make the binary search
    while left < right:

        # compute the middle
        mid = left + (right-left)//2

        # check the mid
        if comparator(arr[mid], target) == -1:
            left = mid+1
        else:
            right = mid
    return right+1


# use custom comp function for python sorting similar to
# https://stackoverflow.com/questions/32752739/how-does-the-functools-cmp-to-key-function-work
def main2():

    # get the inputs
    inputs = read_input()

    # make the comparator function to a key function according to the stackoverflow answer above
    key = functools.cmp_to_key(list_comparison)

    # sort the inputs
    inputs.sort(key=key)

    # make the bisection
    first = custom_bisect(inputs, [[2]], list_comparison)
    second = custom_bisect(inputs, [[6]], list_comparison) + 1
    print(f'The result for solution 2 is: {first*second}')


if __name__ == '__main__':
    main1()
    main2()
