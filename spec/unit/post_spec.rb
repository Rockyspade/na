require 'spec_helper'
require 'helpers'
require 'json'
#require 'io/console'

describe Ayadn::Post do
  before do
    Ayadn::Settings.stub(:options).and_return({
        colors: {
          hashtags: :cyan,
          mentions: :red,
          username: :green,
          id: :blue,
          name: :yellow,
          source: :blue,
          symbols: :green,
          index: :blue,
          date: :cyan,
          link: :magenta
        },
        timeline: {
          show_real_name: true,
          show_date: true,
          show_symbols: true,
          show_source: true
        },
        formats: {table: {width: 75}},
        counts: {
          default: 33
        }
      })
    Ayadn::Settings.stub(:config).and_return({
        identity: {
          username: 'test',
          handle: '@test'
        },
        post_max_length: 256,
        message_max_length: 2048,
        version: 'wee'
      })
    Ayadn::Settings.stub(:user_token).and_return('XYZ')
    Ayadn::Settings.stub(:check_for_accounts)
    Ayadn::Errors.stub(:warn).and_return("warned")
    Ayadn::Logs.stub(:rec).and_return("logged")
  end

  let(:post) { Ayadn::Post.new }
  let(:rest) {Ayadn::CNX = double} #verbose in RSpec output, but useful

  describe "#post" do
    before do
      rest.stub(:post).and_return(File.read("spec/mock/posted.json"))
    end
    it "should raise an error if args are empty" do
      printed = capture_stdout do
        post.post([])
      end
      expect(printed).to include "You should provide some text."
    end
    it "posts a post" do
      expect(rest).to receive(:post).with("https://api.app.net/posts/?include_annotations=1&access_token=XYZ", {"text"=>"YOLO", "entities"=>{"parse_markdown_links"=>true, "parse_links"=>true}, "annotations"=>[{"type"=>"com.ayadn.user", "value"=>{"+net.app.core.user"=>{"user_id"=>"@test", "format"=>"basic"}}}, {"type"=>"com.ayadn.client", "value"=>{"url"=>"http://ayadn-app.net", "author"=>{"name"=>"Eric Dejonckheere", "username"=>"ericd", "id"=>"69904", "email"=>"eric@aya.io"}, "version"=>"wee"}}]})
      x = post.post(['YOLO'])
    end
    it "returns the posted post" do
      x = post.post(['whatever'])
      expect(x['data']['text']).to eq 'TEST'
    end
  end

  describe "#reply" do
    it "formats a reply" do
      new_post = "Hey guys!"
      replied_to = {1=>{:handle => "@test",:username => "test", :mentions => ["user1", "user2"]}}
      expect(post.reply(new_post, replied_to)).to eq "@test Hey guys! @user1 @user2"
      replied_to = {1=>{:handle => "@test",:username => "test", :mentions => ["user1", "test"]}}
      expect(post.reply(new_post, replied_to)).to eq "@test Hey guys! @user1"
      replied_to = {1=>{:handle => "@yo",:username => "test", :mentions => ["test", "lol"]}}
      expect(post.reply(new_post, replied_to)).to eq "@yo Hey guys! @lol"
    end
  end

  describe "#text_is_empty?" do
    it "checks if empty" do
      expect(post.text_is_empty?(["allo"])).to be false
      expect(post.text_is_empty?([""])).to be true
      expect(post.text_is_empty?([])).to be true
    end
  end

  describe "#markdown_extract" do
    it "splits markdown" do
      expect(post.markdown_extract("[ayadn](http://ayadn-app.net)")).to eq ["ayadn", "http://ayadn-app.net"]
    end
  end

  describe "#get_markdown_text" do
    it "extracts markdown text" do
      expect(post.get_markdown_text("[ayadn](http://ayadn-app.net)")).to eq "ayadn"
    end
  end

  describe "#check_post_length" do
    it "checks normal post length" do
      expect(post.check_post_length(["allo", "wtf"])).to be nil #no error
    end
    it "checks excessive post length" do
      printed = capture_stderr do
        expect(lambda {post.check_post_length(["allo", "wtf dude", "ok whatever pfff", "Black malt berliner weisse, filter. Ibu degrees plato alcohol. ipa hard cider ester infusion conditioning tank. Dry stout bottom fermenting yeast wort chiller wort chiller lager hand pump ! All-malt dunkle bright beer grainy, original gravity wheat beer glass."])}).to raise_error(SystemExit)
      end
      expect(printed).to include 'Canceled: too long. 256 max, 32 characters to remove.'
    end
  end

  describe "#check_message_length" do
    it "checks normal message length" do
      expect(post.check_message_length(["allo", "wtf"])).to be nil #no error
    end
    it "checks excessive message length" do
      printed = capture_stderr do
        expect(lambda {post.check_message_length(["Black malt berliner weisse, filter. Ibu degrees plato alcohol. ipa hard cider ester infusion conditioning tank. Dry stout bottom fermenting yeast wort chiller wort chiller lager hand pump ! All-malt dunkle bright beer grainy, original gravity wheat beer glass!!" * 8])}).to raise_error(SystemExit)
      end
      expect(printed).to include 'Canceled: too long. 2048 max, 40 characters to remove.'
    end
  end
end
