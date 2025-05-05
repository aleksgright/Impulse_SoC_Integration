def foo(a: int, b: int, c: int, d: int) -> int:
    tmp = ((a - b) * (1 + 3 * c) - 4 * d) // 2
    if tmp < 0:
        tmp += 1
    return tmp


def verify(a: int, b: int, c: int, d: int, res: int) -> bool:
    return foo(a, b, c, d) == res

errors_present = False
with open("log.txt", 'r') as f:
    lines = [line for line in f]
    for line in lines:
        args = [int(x) for x in line[:-1].split(" ") if x != '']
        # print(args)
        if not verify(args[0], args[1], args[2], args[3], args[4]):
            errors_present = True
            print(f"error! input: a = {args[0]}, b = {args[1]}, c = {args[2]}, d = {args[3]}, expected = {foo(args[0], args[1], args[2], args[3])}, actual = {args[4]}")

if errors_present:
    print("Testbench or module is incorrect")
else:
    print("Tests passed")