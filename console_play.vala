string format_state(Nim nim)
{
	unowned int[] state = nim.state;
	var builder = new StringBuilder();
	builder.printf("%d", state[0]);
	for (int i = 1; i < state.length; i++) {
		builder.append_printf(" %d", state[i]);
	}
	return builder.str;
}

bool play()
{
	var nim = new Nim(3, 5, 15);
	unowned string prompt = "> ";
	while (!nim.is_end()) {
		stdout.printf("%s\n", format_state(nim));
		stdout.printf(prompt);
		int i, n;
		if (stdin.scanf("%d %d", out i, out n) != 2)
			break;
		if (!nim.pick(i, n)) {
			prompt = "?> ";
			continue;
		}
		stdout.printf("%s\n", format_state(nim));
		if (nim.is_end())
			return true;
		nim.step();
		prompt = "> ";
	}
	return false;
}

void main()
{
	stdout.printf("You %s.\n", play() ? "win" : "lose");
}

// vim: ft=vala
