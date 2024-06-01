# Ascent

Submission for MiniJam 155

### Some useful git commands

- ```
  git clone https://github.com/gamesforkings/Ascent.git
  ```
- git add * (add everything for staging) or git add <filename> 
- git commit -m “your commit message” (confirm your changes with a commit message)
- ```
   git push 
  ```
  (This pushes your changes to github)
- ```
  git checkout -b <new branch name>
  ```
- As good practice, every new change let's commit to a new branch and then merge to main
- 
```
git merge <branch to merge from>
```
- So for example if I am on branch 2 and I want to combine the code from branch 1 I do:
- git merge branch1
- This will bring the changes from branch 1 onto branch 2 With possibly merge conflicts depending on the code impacted
- Pull up to date changes from remote (should do this frequently to ensure we're all on the same page)
```
git pull
```
#### Typical work flow

You want to add something to the game?
- Create a new feature branch from main doing the following command:
  ```
  git checkout -b feature-name
  ```
- Add your changes
- Once you're done working on a single feature, its time to commit your changes
### Staging Your Changes
- First stage all your changes
```
git add *
```
or whatever changes you wish to stage
```
git add <file_name>
```
### Committing your changes
- Commit your changes with a descriptive name of the change
```
git commit -m "I completed adding feature name"
```
### Pushing your changes to github
- Finally push all your changes to github
```
git push
```
If the branch hasn't been created remotely yet then you'll have to do this instead:
```
git push -u origin <feature-name>
```
If you don't want to keep doing this you can change your config to do this automatically
```
git config --global push.default current
```
### Merging your changes to main
Finally, if everything looks good, you can merge your changes to the main branch by putting a pull request
This can be done through github by doing the following:
- On the main page of the repo, to the right of issues click Pull Requests
- On the right side of the screen, click the green button "New Pull Request"
- You'll see something along the lines of "base:main" and then an arrow pointing to the left followed by "compare:main"
- Click the dropdown for compare main and then select your feature branch
- Click Create Pull Request
- Type in a message for your pull request and then complete it
- Wait for a review or auto merge if you feel like its ready

- And thats it! Now you have created a new feature 

