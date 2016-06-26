[Compact]
public class Nim {
	public int[] state;
	public Nim(int n, int min, int max)
	{
		state = new int[n];
		for (int i = 0; i < state.length; i++) {
			state[i] = Random.int_range(min, max+1);
		}

	}
	public void step()
	{
		int xorsum = 0;
		foreach (int i in state)
			xorsum ^= i;
		if (xorsum != 0) {
			for (int i = 0; i < state.length; i++) {
				int n = state[i];
				int m = n - (n ^ xorsum);
				if (m > 0) {
					pick(i, m);
					break;
				}
			}
		} else {
			for (int i = 0; i < state.length; i++) {
				int n = state[i];
				if (n > 0) {
					pick(i, Random.int_range(0, n) + 1);
					break;
				}
			}
		}
	}
	public bool pick(int i, int n)
	{
		if (0 <= i && i < state.length && 0 < n && n <= state[i]) {
			state[i] -= n;
			return true;
		}
		return false;
	}
	public bool is_end()
	{
		foreach (int i in state)
			if (i > 0)
				return false;
		return true;
	}
}
