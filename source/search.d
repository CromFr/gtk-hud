module search;

import std.stdio;
import std.string;
import std.uni;
import std.algorithm;
import std.conv : to;
import std.typecons : Tuple;
import std.traits : isSomeString;



//The fuzzy match is a bit tweaked
// Each character from the pattern must be found in the text in the same order
// It assigns higher strength for:
//	- Consecutive characters
//  - Capital characters





alias FuzzyMatch = Tuple!(uint,"strength",size_t[],"indexes");
//Return:
//  strength: 0 if dont match, otherwise a number >0
//  indexes: char indexes in the text that match the best.
FuzzyMatch fuzzyMatch(S)(in S text, in S pattern) if(isSomeString!S){
	if(pattern is null || text is null)
		return FuzzyMatch(1,null);

	size_t[][] validIndexes;
	recurMatch(text, pattern, validIndexes);

	////print indexes
	//foreach(indexes ; validIndexes){
	//	string outText;
	//	size_t lastIndex = 0;
	//	foreach(index ; indexes){
	//		outText ~= text[lastIndex .. index]~"\x1b[1;92m"~text[index]~"\x1b[m";
	//		lastIndex = index+1;
	//	}
	//	outText ~= text[lastIndex .. $];
	//	writeln(outText);
	//}

	//Estimate strength
	FuzzyMatch ret = FuzzyMatch(0,null);
	foreach(indexes ; validIndexes){
		int strength;

		//calculate strength
		foreach(i, index ; indexes){
			strength+=1;

			if(i>0 && indexes[i-1]==index-1)
				strength+=5;//Consecutive match

			if(text[index].isUpper)
				strength+=1;//Capital letter
		}

		if(strength>ret.strength){
			ret = FuzzyMatch(strength, indexes);
		}
	}

	return ret;

}

private
void recurMatch(S)(in S txt, in S pat, ref size_t[][] validIndexes, size_t[] currentIndexes=null) if(isSomeString!S){

	if(txt.length==0 && pat.length>0)
		return;//no text and yet some chars to match

	if(pat.length==0){
		//Matched
		validIndexes ~= currentIndexes;
		return;
	}

	auto indexes = indexList(txt, pat[0]);
	if(indexes.length == 0)
		return;//No match found in the remaining text
	else{
		immutable offset = currentIndexes.length>0? currentIndexes[$-1]+1 : 0;
		foreach(i ; indexes){
			recurMatch(txt[i+1..$], pat[1..$], validIndexes, currentIndexes~(i+offset));
		}
	}
}
unittest{
	size_t[][] indexes;
	recurMatch("loldl", "lol", indexes);
	assert(indexes.equal([[0,1,2],[0,1,4]]));
}

private
size_t[] indexList(S)(in S text, in dchar c, size_t _=0) if(isSomeString!S){
	auto found = text.indexOf(c, 0, CaseSensitive.no);
	if(found==-1)
		return null;
	return found+_ ~ indexList(text[found+1..$], c, _+found+1);
}
unittest{
	assert(indexList("ababab", 'a').equal([0,2,4]));
	assert(indexList("ababab", 'b').equal([1,3,5]));
}