# manl

Manl combines a manpage, prepended with your personal notes in a CLI or GUI editor.			<br>
Makes it convenient to create/edit and save new/edited notes while reviewing manpages.			<br>
Automatically seperates notes from manpage and saves notes to ~/.manl/\<manpage name\>.			<br>
													<br>
Copy/paste in an editor, information from manpages, add content, save to your notes.			<br>
File name and path  are preset by manl, just save your changes.						<br>
Next time you use manl <manpage>, your notes will be printed above the manpage.				<br>
													<br>
Operations:												<br>
    -h --help  =  help page										<br>
    -Sn        =  Search for \<manpage\> numbers							<br>
    -St        =  Search manpages for \<term\> "man -k \<term\>"					<br>
													<br>
Usage:													<br>
    manl [operation] <manpage> -or-  manl \<number manpage\>						<br>
Examples:												<br>
    manl signal                -or-  manl 7 signal							<br>
    manl -Sn signal											<br>
													<br>
Screenshot manl: https://cody-learner.github.io/find.html 						<br>
													<br>
													<br>
**UPDATE For  Feb 25 and 26, 2024**									<br>
Man pages added an empty line at beginning, breaking the 'del' variable.				<br>
Revised code to detect first non empty line.								<br>
Removed function wrapping entire script that was attempting to background it in the shell.		<br>
Added some troubleshooting information code.								<br>
Revised printed to shell message for clarity.								<br>
Added the "-i" edit in place option to sed resulting in code reducion.					<br>
Added comment related to shell check.									<br>
