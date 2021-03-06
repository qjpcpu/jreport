# Jreport

Jreport is used for the scenerio: collect and sort data, then make a report and send to someone. With jreport, you can focus on how to collect and sort data, and jreort would merge the data to the html template you design, then it will send the report to someoen you specfic. If you're a rails developer, you would get started quickly.

## Installation

Add this line to your application's Gemfile:

    gem 'jreport'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install jreport

## Usage

### Create a jreport project

	jreport new example
	
The project looks like:

	example
	├── Gemfile
	├── boot.rb
	├── collectors
	├── config
	├── controllers
	├── db
	│   ├── connection.rb
	│   ├── database.yml
	│   └── migrate
	├── helpers
	├── models
	├── rakefile
	└── views

### Create a jreport scaffold

	jreport generate scaffold weather daily weekly
	
Command above means we will collect some weather data, then we would use this data to produce two report: a daily report and a weekly report.

#### Collector

Check the project folder, this command create weather_collector.rb in collectors folder, the WeatherCollector class contains a method fetch_data.
You'd better return the data with the method.
For example:

	class WeatherCollector
		def fetch_data
			#TODO: add code here
	    [1,2,3,4]
		end
	end

You can return any ruby object, only if you know what it is. 
Besides, if you use active-record to store the data you get, you can even return nothing here.

#### Controller

Below the controllers folder, jreport create weather_controller.rb, with the last two arguments of 'jreport generate scaffold' command, WeatherController has two methods: daily_report and weekly_report. In this method, you can filter the data as you like(with data and data= method). 

But it's important to specify email configurations(from,to,subject). You can use the mail argument to cover this.

And you can save final html string to 'save_to'.

	class WeatherController
	# The method looks like xxx_report would be used to generate report
		def daily_report(mail)
			# TODO: add code here
	    	self.data=self.data.first
    		mail.from='from@example.com'
    		mail.to='to@example.com'
	    	mail.subject='example daily report'
			mail.content_type="text/html;charset=UTF-8"
		end
		def weekly_report(mail)
			# TODO: add code here
	    	mail.from='from@example.com'
	    	mail.to='to@example.com;to1@example.com'
	    	mail.subject='example weekly report'
			mail.content_type="text/html;charset=UTF-8"
    
    		self.save_to='/home/jreport/example_w.html'
		end
	end

#### View

In views folder, there is a folder weather contains 4 files. File daily_report.eruby and daily_report.css for the daily report, the other two are for weekly report.

You can complete a beautiful template accroding to erubis grammar, and the css code should be put into *.css file.

This is a simple weekly report template:

	<h1>weekly</h1>
	<%= data %>

Note: in the template you can use helper method that is defined in helpers folder. You can access the active record classes, too.

For example. If you have a file `number_helper.rb` in helper folder:

	module NumberHelper
	    def pretty_number(num)
	        num,result=num.to_s,''
	        num.reverse.split('').each_with_index{|v,i| result<<v;result<<',' if (i+1)%3==0}
	        result=result[0..-2] if result[-1]==','
	        result.reverse
	    end
	end
	
Then you can use the helper method `pretty_number` directory in views as: `<%= pretty_number 1234345 %>`

### Gnerate report

	jreport make weather
	
Then jreport would send two email: daily report and weekly report.

### Use active record

Create active record is similar to rails:

	jreport generate model man name:string
	
That create a migration file under db/migrate and a class file under models.

You can migrate db changes:

	rake db:migrate

P.S. See all available rake command:

	rake -T
	
Besides, you can access database directly in `irb`:

	require './boot.rb'

	
### Mail configuration example(from [mail](https://github.com/mikel/mail))

1. Change default delivery method

	Change global delivery method it in `example/config/mail_config.rb`, or just change for this report:

		mail.delivery_method :smtp,address: "localhost", port: 1025
	
2. Add attachment file

		mail.add_file '/path/to/file'
		# or
		mail.add_file :filename=>'somefile.png',:content=>'/path/to/f.png'
		
    If you add a picture, and want to make it an embbeded picture,you can:

        # First add it as attachemnt in controller
        mail.add_file '/path/to/picture_name'
        # Then in view
        <img src="<%=attachments['picture_name'].url>"/>
        # or if this is the only attachemnt
        <img src="<%=attachments.first.url>"/>

3. Add cc

		mail.cc="other@example.com"

### Others

* More email detail configurations, please check [mail](https://github.com/mikel/mail).
* View template details, please check [erubis](https://github.com/genki/erubis).

## Contributing

1. Fork it ( http://github.com/<my-github-username>/jreport/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
