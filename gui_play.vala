class SpinArray : Object {
	Gtk.SpinButton[] buttons;
	public signal void state_notify(bool dirty);

	public delegate void ForeachCallback(Gtk.SpinButton button);
	public void @foreach(ForeachCallback callback)
	{
		foreach (unowned Gtk.SpinButton button in buttons)
			callback(button);
	}
	public SpinArray(int N)
	{
		buttons = new Gtk.SpinButton[N];
		for (int i = 0; i < N; i++) {
			buttons[i] = new Gtk.SpinButton.with_range(0, 0, 1);
			buttons[i].value_changed.connect(on_spin_value_changed);
		}
	}
	public void get_active(out int i, out int val)
	{
		i = 0;
		val = -1;
		foreach (unowned Gtk.SpinButton button in buttons) {
			if (button.sensitive) {
				val = (int) button.value;
				return;
			}
			i++;
		}
	}
	public void reset(int[] val)
		requires(val.length == buttons.length)
	{
		for (int i = 0; i < val.length; i++) {
			buttons[i].set_range(0, val[i]);
			buttons[i].value = val[i];
		}
		state_notify(false);
	}
	void on_spin_value_changed(Gtk.SpinButton button) {
		double min, max;
		button.get_range(out min, out max);
		bool dirty = (button.value < max);
		foreach (unowned Gtk.SpinButton button1 in buttons) {
			button1.sensitive = !dirty || (button == button1);
		}
		state_notify(dirty);
	}
}

class NimWindow : Gtk.Window {
	int N;
	SpinArray spins;
	Nim nim;

	public NimWindow(int N)
	{
		this.N = N;
		this.title = "Nim Game";
		this.spins = new SpinArray(N);

		var vbox = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);

		Gtk.ButtonBox button_box = new Gtk.ButtonBox(Gtk.Orientation.HORIZONTAL);
		var submit_button = new Gtk.Button.with_mnemonic("_Submit");
		submit_button.clicked.connect(this.on_submit);
		button_box.add(submit_button);
		var reset_button = new Gtk.Button.with_mnemonic("_Reset");
		reset_button.clicked.connect(this.load_state);
		button_box.add(reset_button);

		this.spins.state_notify.connect((dirty) => { button_box.sensitive = dirty; });
		this.spins.foreach((button) => vbox.add(button));
		vbox.add(button_box);

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
		spins.reset(nim.state);
	}
	void on_submit()
	{
		int i;
		int val;
		spins.get_active(out i, out val);
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
