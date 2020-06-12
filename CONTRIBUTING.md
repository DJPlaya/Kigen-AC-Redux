# Contribution Guidelines

**Index of Contents**
* What Chances do I have to add new Code to KACR?
	* Through Pull Requests
	* Write/Push Access (Direct Committing)
* General Rules
* Checklist before submitting Pull Requests / committing new Code
	* How Commits should look like
* Consistent Code Style
	* Code Style Example

## What Chances do I have to add new Code to KACR?

If you want to help you can Contribute to the Project by submitting Code, Bugs, False-Positives, Wiki Entrys and Translations.
The Chances that your Content will be added are quite high if you provide a useful Feature, working Bugfix or the like.

### Through Pull Requests

This will require you to fork this Project to your own User first, do/commit the Changes there and create a new Pull Request from the master Branch of your Repository to here.

[Here is a more detailled Description on how to do it.](https://help.github.com/articles/using-pull-requests)

Also: read the rest of this Document first.

### Write/Push Access (direct committing)

We give People push Access who have already done some successful Pull Requests.

[Create an issue](https://github.com/DJPlaya/Kigen-AC-Redux/issues/new?assignees=DJPlaya&labels=question&title=Requesting%20to%20become%20Part%20of%20the%20Team), if you feel you would be a good Team Member/Contributor.

## General Rules

* Only add Game-independent Code (try to find the lowest common Denominator between Games), if a Feature is only supported by one game, create a new File/Namespace for this specific Game
* Use a (to this Project) consistent Code Style
* Don't add Code that uses virtual Offsets/Function Signatures/Symbols. KACR is supposed to be work everywhere and without any Knowledge on how to install it
* Write long, self-explaining Function/Variable Names.
* If you add code from other People, don't forget to mention that in a Function Annotation/Comment
* Document all Functions with Annotations (have a look at other Functions for Examples)
* Comment your Code (That's also useful for Yourself, you will forget about Things after some Time)
* Do not add useless Dependencys and if so, make them optional
* If you are working on a bigger Feature that will require multiple Commits to be made, consider creating a new Feature Branch ("Feature-yourfeaturename") and make a Pull Request when you are done to merge it with the Master
* Write re-usable, capsulated, readable and clean Code
* Don't use the Function "ServerCommand", unless you have a really really really good Reason to do so.
* Don't add Code which could make KACR, the Server or the Client unstable. The highest Priority is to have worling Protection no matter what happens.
* All Nouns and proper Names must be capitalized - Everywhere
* 

## Checklist before submitting Pull Requests / committing new Code

* Rules: Read?
* Consistent Code Style
* Documentation written (Function Annotations, Comments)

### How Commits should look like
* Write a Summary of what you did into the First Commit Message Line, and more detailed Information into the next Lines
* Avoid pushing merge Commits (within the same Branch), they pollute the Histoy. Use `git rebase` to stack Commits. [Here](http://randyfay.com/content/simpler-rebasing-avoiding-unintentional-merge-commits) is a good Tutorial.
* Use `+`, `*` and `-` for Key Points in your Commit Details to mark your Code Changes as added(`+`), changed(`*`) or removed(`-`).
This can look like this:  
+Added WIP Update System  
*Renewed Syntax  
-Backchecking Function got Removed

## Consistent Code Style

* We use Tabs for Intendation
* We use Whitespaces for aligning Code in-Line
* Use long, self-explaining Variable/Function Names
* ALWAYS use `{` `}` Brackets but do avoid them when an new Block only has a single Line
* Don't use Abbrevations anywhere in Function/Variable Names etc., except they are well-known or have been mentioned a few Lines earlyer in the Code.
* Use New Lines to Group your Code into logical Parts and do use theese Comments for new Sectors/Groups `//- GROUP -//`
* Do not make a Line Break if the Line is too long
* Use the new Syntax and dont forget to optimize every bit of Code ;)
* Global Variables must be marked with `g_`, and ConVars with `g_hCVar`
* Variable Names must contain the Data Type and each Word must be capitalized like this: `ConVar g_hEyetestEnabled` (`g_` because it is global and `h` because an ConVar is a type of Handle).
* All Convars must be Hooked to detect Changes, the Function Name must begin with `ConVarChanged_`
* When defining Vars, do not make Bools = False and Handle = Invalid_Handle, invalid/false/0 are the default Values
* Allways leave one Line of Space before using `return`, `break` or similar
* There must be a Gap after an `if`/`else`/`case` if Code comes after that
* Use the `TODO` Marker in Comments to label unfinished of not optimal Stuff that may needs to be worked on further
* Use the `BUG` Marker for possible Bugs and Exploits in the Code

### Code Style Example
```Sourcepawn
/**
 * Describe the Function here
 *
 * @param iClient	Client to Target.
 * @return		True if succesfull.
 */
~~stock~~ SomeFunction(int iClient) // "stock" just means it dosent get compiled if unused
{
	bool bBool1, bBool2; // Default Value is false
	bool bBool3 = true; // We split this to a new Line
	// Mind the Gap
	for (int iClient = 1; iClient < = MaxClients; iClient++) // Mind the Gap after the for
	{
		if (bBool1 != bBool2) // Mind the Gap after the if
		{// if, else Brackets on same Line
			// Code
			// Code
		}
		// There must be a Gap after an if/else/case if Code comes after that
		else // Do not open Brackets for Oneliners
			DoStuff();
			// Gap and Tab till next Function if open
		return;
	}
	// Allways a Gap before using return, break or similar
	return Plugin_Handled;
}
```

Note: Original Text from SMLib, Copyright (C) SMLIB Contributors
