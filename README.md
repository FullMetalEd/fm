# fm

### FullMetal Function Managment command.

Created by FullmetalEd.

Under active development...

This is used for script and function execution and management.
It is built dynamically so that new scripts or functions can be added at anytime. FullMetal fm can pull metadata like help information
from the provided scripts.

 #### Useage.

 ```fm -h``` or ```fm --help``` will show more usage information.

 ```fm``` will show you all the available functions, you can select one to see it's help information.

 ```fm <script>```, listing the help metadata for the specified function/script. i.e. ```fm mkf```.

 You can perform actions by providing the script name and any inputs it needs: ```fm mdf ./path/to/file/readme.md```.

 If there is a scenario where ```fm``` does not know what script you want, it will provide a fzf searchable list of all available functions so you can search and pick one, then all the inputs you provided will be passed to this command. i.e. ```fm mk ./path/to/file/readme.md``` will show fzf with ```mkd``` and ```mkf``` as options.

 #### Installation.
