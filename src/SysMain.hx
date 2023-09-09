package ;
import sys.io.File;
using StringTools;

/**
 * ...
 * @author YellowAfterlife
 */
class SysMain {
	static var config:VilToDrawerOpt = new VilToDrawerOpt();
	
	static function error(text:String) {
		Sys.println(text);
		Sys.exit(1);
	}
	static function getText(path:String) {
		try {
			var text = File.getContent(path);
			text = text.replace("\\r", "");
			return text;
		} catch (x:Dynamic) {
			error('Failed to read "$path":' + x);
			return null;
		}
	}
	static var cliOpts:Array<CommandLineOption> = [
		new CommandLineOption("help", [], function() {
			help();
		}, [
			"Shows this documentation and exits.",
		]),
		
		new CommandLineOption("vil", ["path"], function(path) {
			config.parseVil(getText(path));
		}, "Specifies a .vil file to convert"),
		
		new CommandLineOption("keyboard", ["name"], function(val) {
			config.qmkKeyboard = val;
		}, [
			"Specifies a QMK keyboard name to use, such as",
			"corne_rotated",
			"splitkb/aurora/sofle_v2/rev1",
			"Find the name in configurator: https://config.qmk.fm/",
		]),
		new CommandLineOption("layout", ["name"], function(val) {
			config.qmkLayout = val;
		}, [
			"Specifies a physical layout to use, if keyboard has multiple.",
			"For example, corne_rotated has a LAYOUT_split_3x5_3.",
		]),
		
		new CommandLineOption("layer-names", ["path"], function(path) {
			config.parseLayerNames(getText(path));
		}, [
			"Specifies a file to load layer names from (one per line)",
		]),
		new CommandLineOption("key-labels", ["path"], function(path) {
			config.parseKeyOverrides(getText(path));
		}, [
			"Specifies a file to load key label overrides from. One per line, formatted as",
			"layer number, row, col => new key text",
			"For example,",
			"0,1,2 => COOL",
			"Would replace the label on third key in second row in first layer by COOL.",
		]),
		
		new CommandLineOption("half-after-half", [], function() {
			config.halfAfterHalf = true;
		}, [
			"Specifies that keys are stored half-by-half and row-by-row",
			"(L1, L2, L3, R1, R2, R3 instead of L1, R1, L2, R2, L3, R3)",
		]),
		new CommandLineOption("mirror-right-half", [], function() {
			config.mirrorRightHalf = true;
		}, [
			"Specifies that keys on the right half of keyboard are stored right-to-left",
			"Happens to keyboards where the PCB and software is identical for two halves",
		]),
		
		new CommandLineOption("move-defs", ["path"], function(path) {
			config.parseMoveDefs(getText(path));
		}, [
			"Specifies a file to load key move definitions from. One per line, formatted as",
			"old row, old col => new row, new col",
			"For example,",
			"1,2 => 0,5",
			"Would move third key from second row to sixth position in the first row.",
			"Rows and columns are counted as they appear in .vil",
		]),
	];
	
	static function help() {
		CommandLineOption.print(cliOpts);
		Sys.exit(0);
	}
	public static function main() {
		var args = Sys.args().copy();
		if (args.length == 0) help();
		
		try {
			CommandLineOption.run(args, cliOpts);
		} catch (x:Dynamic) {
			error("Error processing arguments: " + x);
		}
		
		if (args.length < 1) {
			error("Expected a .yaml path apart of the options");
		} else if (args.length > 1) {
			error('Multiple candidates for YAML path: ["' + args.join('","') + '"]');
		}
		var yamlPath = args[0];
		
		Sys.println("Converting...");
		var yamlTxt = VilToDrawer.runTxt(config);
		Sys.println('Writing to "$yamlPath"...');
		File.saveContent(args[0], yamlTxt);
		Sys.println("OK!");
	}
}