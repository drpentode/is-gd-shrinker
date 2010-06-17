require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Shrinker" do
  it "should shorten a URL" do
    new_url = Shrinker.shrink("http://www.google.com/")
    new_url.should match(/http:\/\/is.gd\/[a-z]*/)
  end

  it "should raise a ShrinkError if input URL is not valid" do
    lambda {Shrinker.shrink("boogers")}.should raise_error(ShrinkError, "Supplied URL was not formatted as a URL.  Please format it as http://www.domain.com/")
  end

#  Any Rspec Gurus know how to stub OpenURI.open_uri without passing around a mocked kernel?
#  it "should raise an error if is.gd cannot be reached" do
#    OpenURI.stub!(:open_uri).with(any_args()).and_raise(OpenURI::HTTPError)
#    lambda {Shrinker.shrink("http://www.google.com/")}.should raise_error(ShrinkError, "No URL was returned from is.gd.  There was an error accessing the service.")
#  end

  it "should expand a URL" do
    shrunken_url = Shrinker.shrink("http://www.on-site.com/")
    new_url = Shrinker.expand(shrunken_url)
    new_url.should == "http://www.on-site.com/"
  end

  it "should raise a ShrinkError if the input URL is not valid" do
    lambda {Shrinker.expand("boogers")}.should raise_error(ShrinkError, "Supplied URL was not an is.gd URL.  Please use a valid is.gd URL.")
  end
end
