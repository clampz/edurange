# EDURange Documentation
## What is it?

EDURange is an NSF-funded project with the aim of building a platform for cloud-based interactive computer security exercises. 


## Developer Installation

To setup the developer server to run on your machine, there are five main steps.

1. Clone the repository from github
2. Install the rails and ruby packages necessary to run and manage EDURange 
  - RVM (Ruby Version Manager)
  - rails
  - rubygems
  - bundler
3. Create local settings for aws options.
  - In the config directory, copy settings.yml to settings.local.yml
  - Fill in blank fields in settings.local.yml with settings obtained from a developer
4. Add aws credentials to your machine's ENV variables.
5. Run the server, and create a new user

Please follow each step carefully. A small error will likely result in a rails environment that simply won't work. Contact a EDURange developer if you run into problems that you can't solve after google and a few tries.


####  I. Clone the git repository:
```bash
git clone https://github.com/edurange/edurange-server.git
```

####  II. Install RVM (Ruby Version Manager), rails, rubygems, and bundler

  Follow this guide: (https://rvm.io/rvm/install). This project uses Ruby 2.1.5 so use RVM to install and select the    correct   version of Ruby:
```bash
rvm install [ruby version number eg 2.2.1]
rvm use [ruby version number eg 2.2.1]
```

You may have to do something like: `bin/bash --login` in order to set the RVM ruby version (which doens't refer to the system ruby version).

Also, install bundler (to take care of gem dependencies) and the rails framework:

Debian/Ubuntu Linux:
```bash
sudo apt-get install rubygems
sudo apt-get install rails
sudo gem install bundler
```
Fedora/Red Hat Linux
```bash
sudo yum install rubygems
sudo yum install rubygem-{rails}
sudo gem install bundler
```

To finish up the installation, yank and update all the gem dependencies:
```bash
bundle update
bundle install
```

####  III. Ask a current developer to get the proper settings for your config/settings.local.yml file

Create a new configuration file by copying config/settings.yml to config/settings.local.yml

Your settings file should look something like this:
```bash
# NOTE -- DO NOT EDIT THIS FILE. IT IS NOT IN .gitignore. COPY THIS FILE TO config/settings.local.yml, AND EDIT THAT.
ec2_key: # name of AWS Key Pair
driver: aws
bucket_name: # AWS globally unique bucket name
app_path: ./
host: # your hostname
boot_asynchronously: false
vpc_limit: # your AWS VPC Limit
ami_nat:
ami_ubuntu:
endpoint: #your aws region endpoint
```

As the file specifies, DO NOT edit the settings.yml, but only the new settings.local.yml you've just created. Fill in the rest of the setting fields with data that a current developer provides you.


####  IV. Contact the project aws administrator to get the credentials to place in your ENV variables.

You should recieve three global environment variables from which the AWS code will read to authenticate the creation of EC2 instances. Fire up your favorite text-editor on the ~/.bashrc file and add these lines to the very bottom.

```bash
export AWS_ACCESS_KEY_ID='your-access-key-id'
export AWS_SECRET_ACCESS_KEY='you-secret-access-key'
export AWS_REGION='your-aws-region'
```


Now you should be all ready to start your server and create some users.

####  V. Run the server and create a user
  
Once you've got the development environment put together the dev server can be started.
If this is your first time running the edurange you'll probably have to run a database migration by saying:
```bash
bin/rake db:migrate RAILS_ENV=development
```

Now bootup the developement server:
```bash
rails server
```
If you get a ruby version error, you might need to type 'rvm 2.2.1 [or current ruby version in Gemfile]'.
Point your web browser to localhost:3000 and you should see something like this:
![alt tag](http://i.imgur.com/2HR5k9K.jpg?1)

Currently you have no users locally stored in your database, so we'll have to drop into a ruby interpreter and create one. Open a new terminal, cd to the edurange directory and execute the following:
```bash
rails console
```
Which should drop you into a ruby shell. Next we'll connect to the user table of the database and create a user within the table using the Ruby ORM.
```ruby
2.1.5 :001 > User.connection()  # make connection to db
2.1.5 :002 > User.all()  # look at all users, notice there are none.
  User Load (3.2ms)  SELECT "users".* FROM "users"
 => #<ActiveRecord::Relation []> 
2.1.5 :003 > u = User.new(id: 1, name: "admin", email: "admin@edurange.org")  # create a new user
 => #<User id: 1, email: "admin@edurange.org", encrypted_password: "", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, sign_in_count: 0, current_sign_in_at: nil, last_sign_in_at: nil, current_sign_in_ip: nil, last_sign_in_ip: nil, created_at: nil, updated_at: nil, name: "admin", role: 4, organization: nil, registration_code: nil> 
2.1.5 :004 > u.password = "password_lolz"  # give user a password at least 6 characters long.
 => "password_lolz" 
2.1.5 :006 > u.set_admin_role()  # and set user as admin.
   (0.2ms)  begin transaction
  SQL (0.6ms)  INSERT INTO "users" ("name", "email", "role", "encrypted_password", "created_at", "updated_at") VALUES (?, ?, ?, ?, ?, ?)  [["name", "admin"], ["email", "admin@edurange.org"], ["role", 2], ["encrypted_password", "$2a$10$I5W7il5QqPP0OeResa0DveYH9hrnSbvzMQ5dvwqt6JVk7S5xnp3kK"], ["created_at", "2015-06-23 22:31:35.332502"], ["updated_at", "2015-06-23 22:31:35.332502"]]
   (203.8ms)  commit transaction
 => true 
2.1.5 :011 > u.save()  # save user entry into database.
   (0.1ms)  begin transaction
  User Exists (0.2ms)  SELECT  1 AS one FROM "users" WHERE ("users"."email" = 'admin@edurange.org' AND "users"."id" != 1) LIMIT 1
   (0.1ms)  rollback transaction
 => false 
 2.1.5 :012 > User.all()  # view all users, there is only the one we just created.
  User Load (0.3ms)  SELECT "users".* FROM "users"
 => #<ActiveRecord::Relation [#<User id: 1, email: "admin@edurange.org", encrypted_password: "$2a$10$I5W7il5QqPP0OeResa0DveYH9hrnSbvzMQ5dvwqt6JV...", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, sign_in_count: 0, current_sign_in_at: nil, last_sign_in_at: nil, current_sign_in_ip: nil, last_sign_in_ip: nil, created_at: "2015-06-23 22:31:35", updated_at: "2015-06-23 22:31:35", name: "admin", role: 2, organization: nil, registration_code: nil>]> 

```

With this newly created admin user, try logging into EDURange by using the email and password you supplied earlier. What should come up is a screen that looks like this:
![alt-tag](http://i.imgur.com/fxaqNbc.jpg)


##### Booting a Scenario
Now that you have an admin user you can boot a scenario after some minor configurations. 

After doing that, go ahead and navigate to the "Scenarios" tab and load a new scenario. Choose from the default scenarios available. Once the scenario is loaded you should be brought to a detail view where you can boot the scenario.
