package tools;

/**
 * ...
 * @author YellowAfterlife
 */
class BuildDate {
	public static macro function asString() {
		return macro $v{DateTools.format(Date.now(), "%Y-%m-%d--%H-%M-%S")};
	}
}