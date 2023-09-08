package ;
import haxe.extern.EitherType;

/**
 * ...
 * @author YellowAfterlife
 */
class CommandLineOption {
	public static var prefix:String = "--";
	public var name:String;
	public var args:Array<String>;
	public var func:Dynamic;
	public var desc:Array<String>;
	public function new(name:String, args:Array<String>, func:Dynamic, desc:EitherType<String, Array<String>>) {
		this.name = name;
		this.func = func;
		this.args = args;
		this.desc = desc is String ? [desc] : desc;
	}
	public static function run(args:Array<String>, options:Array<CommandLineOption>) {
		var i = 0;
		while (i < args.length) {
			var arg = args[i];
			if (!StringTools.startsWith(arg, prefix)) {
				i += 1;
				continue;
			}
			var name = arg.substr(prefix.length);
			var opt = options.filter(o -> o.name == name)[0];
			if (opt == null) throw '"$arg" is not a known command-line option.';
			
			var sub = args.slice(i + 1, i + 1 + opt.args.length);
			try {
				Reflect.callMethod(opt, opt.func, sub);
			} catch (x:Dynamic) {
				throw "Error processing " + prefix + opt.name + sub + ": " + x;
			}
			args.splice(i, 1 + opt.args.length);
		}
	}
	public static function print(options:Array<CommandLineOption>) {
		Sys.println("The following options are supported."
			+ " Arguments are denoted in <angle brackets> here");
		for (opt in options) {
			Sys.print(prefix + opt.name);
			for (arg in opt.args) {
				Sys.print(' <$arg>');
			}
			Sys.println("");
			for (line in opt.desc) {
				Sys.println("    " + line);
			}
		}
	}
}
