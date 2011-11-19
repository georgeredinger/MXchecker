require 'resolv'
require 'dalli'

def validate_email_domain(domain)
	Resolv::DNS.open do |dns|
		@mx = dns.getresources(domain, Resolv::DNS::Resource::IN::MX)
	end
	@mx.size > 0 ? 'true' : 'false'
end

def cached_goodness(email,assert)
	domain=email.match(/\@(.+)/)[1]
	if(@cache.get(domain) == nil)
		validity = validate_email_domain(domain)
		@cache.set(domain,validity, ttl=86400)
	end
	validity = @cache.get(domain)
	raise 'hell' if assert != validity
	validity 
end

def goodness(email,assert)
	domain=email.match(/\@(.+)/)[1]
	validity=validate_email_domain(domain)
	raise 'hell' if assert != validity
	validity
end

@cache = Dalli::Client.new('localhost:11211')

start=Time.now
20.times do
	cached_goodness("george@georgeredinger.com",'true')
	cached_goodness("jgoodsen@radsoft.com",'true')
	cached_goodness("nesdoogj@tfosdar.com",'false')
	cached_goodness("nesdoogj@goatsmilkforbreakfastumumgood.com",'false')
	cached_goodness("zodor@incredibleplanet.org",'false')
end
puts "Cached #{((Time.now-start)/100.0)*1000.0} ms per check"

start=Time.now
20.times do
	goodness("george@georgeredinger.com",'true')
	goodness("jgoodsen@radsoft.com",'true')
	goodness("nesdoogj@tfosdar.com",'false')
	goodness("nesdoogj@goatsmilkforbreakfastumumgood.com",'false')
	goodness("zodor@incredibleplanet.org",'false')
end
puts "Not Cached #{((Time.now-start)/100.0)*1000.0} ms per check"


