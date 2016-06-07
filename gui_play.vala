class NimWindow : Gtk.Window {
	int N;
	Gtk.SpinButton[] spins;
	Gtk.ButtonBox button_box;
	Nim nim;

	public NimWindow(int N)
	{
		this.N = N;
		this.title = "Nim Game";
		this.spins = new Gtk.SpinButton[N];

		var vbox = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
		for (int i = 0; i < N; i++) {
			int local_i = i;
			var spin = this.spins[i] = new Gtk.SpinButton.with_range(0, 0, 1);
			vbox.add(spin);
			spin.value_changed.connect(() => this.on_spin_value_changed(local_i));
		}

		this.button_box = new Gtk.ButtonBox(Gtk.Orientation.HORIZONTAL);
		var submit_button = new Gtk.Button.with_mnemonic("_Submit");
		submit_button.clicked.connect(this.on_submit);
		this.button_box.add(submit_button);
		var reset_button = new Gtk.Button.with_mnemonic("_Reset");
		reset_button.clicked.connect(this.load_state);
		this.button_box.add(reset_button);
		vbox.add(this.button_box);

		this.add(vbox);

		this.restart();
	}
	void restart()
	{
		this.nim = new Nim(this.N, 5, 15);
		this.load_state();
	}
	void endgame(bool win)
	{
		var msg = new Gtk.MessageDialog(
			this,
			Gtk.DialogFlags.MODAL,
			Gtk.MessageType.INFO,
			Gtk.ButtonsType.OK,
			"You %s."
			, win ? "win" : "lose"
		);
		msg.run();
		msg.destroy();
		restart();
	}
	void load_state()
	{
		int i = 0;
		foreach (unowned Gtk.SpinButton spin in spins) {
			int val = this.nim.state[i];
			spin.set_range(0, val);
			spin.value = (double) val;
			i++;
		}
		enable_all_spins();
		this.button_box.sensitive = false;
	}
	void on_spin_value_changed(int i)
	{
		unowned Gtk.SpinButton spin = spins[i];
		bool dirty = (spin.value != this.nim.state[i]);
		if (dirty) {
			disable_some_spins(i);
		} else {
			enable_all_spins();
		}
		button_box.sensitive = dirty;
	}
	void disable_some_spins(int except)
	{
		int i = 0;
		foreach (unowned Gtk.SpinButton spin in spins)
			spin.sensitive = (i++ == except);
	}
	void enable_all_spins()
	{
		foreach (unowned Gtk.SpinButton spin in spins)
			spin.sensitive = true;
	}
	void on_submit()
	{
		int i = 0;
		int val = 0;
		foreach (unowned Gtk.SpinButton spin in spins) {
			if (spin.sensitive) {
				val = (int) spin.value;
				break;
			}
			i++;
		}
		nim.pick(i, this.nim.state[i] - val);
		if (nim.is_end()) {
			endgame(true);
		} else {
			nim.step();
			this.load_state();
			if (nim.is_end())
				endgame(false);
		}
	}
}

void main(string[] args)
{
	const int N = 3;
	Gtk.init(ref args);
	var window = new NimWindow(N);
	window.destroy.connect(Gtk.main_quit);
	window.show_all();
	Gtk.main();
}

// vim: ft=vala
