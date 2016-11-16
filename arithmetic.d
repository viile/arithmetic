import std.stdio;
import std.conv;
import std.algorithm;

class Expression
{
	public string[string] vars;
	public float Evaluate(string[string] vars)
	{
		return 0;
	}
}

class Constant : Expression
{
	public float value;
	public this(float value)
	{
		this.value = value;
	}
	override public float Evaluate(string[string] vars)
	{
		return value;
	}
}

class VariableReference : Expression
{
	public string name;
	public this(string name)
	{
		this.name = name;
	}
	override public float Evaluate(string[string] vars)
	{
		return vars[name].to!float;
	}
}


class Operation : Expression
{
	public Expression left;
	public char op;
	public Expression right;
	public this(Expression left,char op,Expression right)
	{
		this.left = left;
		this.op = op;
		this.right = right;
	}
	override public float Evaluate(string[string] vars)  
	{  
		auto x = left.Evaluate(vars);  
		auto y = right.Evaluate(vars);  
		final switch (op)  
		{  
			case '+':return x + y;  
			case '-':return x - y;  
			case '*':return x * y;  
			case '/':return x / y;  
		} 
	}  

}

Expression strToTree(string str,int s,int t)
{
	while (s <= t && str[s] == '(' && str[t] == ')')
	{
		s++; 
		t--;
	}
	if(s > t) return new Constant(0);

	bool findLetter = false;
	bool findChar = false;  
	int brackets = 0;  
	int lastPS = -1;
	int lastMD = -1; 

	for (int i = s;i<=t;i++)
	{
		if (str[i] != '.' && (str[i]<'0' || str[i]>'9'))  
		{  
			if ((str[i] >= 'a' &&str[i] <= 'z') || (str[i] >= 'A'&&str[i] <= 'Z'))  
				findLetter = true;  
			else  
			{  
				findChar = true;  
				final switch (str[i])  
				{  
					case '(':brackets++; break;  
					case ')':brackets--; break;  
					case '+':  
					case '-':if (!brackets)lastPS = i; break;  
					case '*':  
					case '/':if (!brackets)lastMD = i; break;  
				}  
			}  
		} 
	}
	auto ops = ["+","-","*","/"];
	int ts = s;
	while(ts <= t)
	{
		if(canFind(ops,str[ts].to!string))break;
		ts++;
	}
	if (findLetter == false && findChar == false)  
		return new Constant(str[s .. ts ].to!float);  
	if (findChar == false)
		return new VariableReference(str[s.. ts]);  
	if (lastPS == -1)  
		lastPS = lastMD;  
	return new Operation(strToTree(str, s, lastPS - 1 ), str[lastPS], strToTree(str, lastPS + 1,t));
}

void main()
{
	string[string] vars;
	vars["x"] = "123.5";
	vars["y"] = "14";
	vars["z"] = "0.6";

	string str = "x*51+(y/(10.09+z))";

	auto ex = strToTree(str,0,str.length.to!int - 1);
	writeln(ex.Evaluate(vars));
}
