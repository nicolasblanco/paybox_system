require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Paybox::System::Base" do
  subject { Paybox::System::Base }

  describe ".config" do
    it "has an empty config hash" do
      subject.config.should be_a(Hash)
      subject.config.should be_empty
    end

    it "has a setter and getter" do
      subject.config = { :test => "pipo" }
      subject.config.should == { :test => "pipo" }
    end
  end

  describe ".hash_form_fields_from" do
    it "raises an exception if no :secret_key in config" do
      expect { subject.hash_form_fields_from }.to raise_error
    end

    context "with :secret_key in config hash" do
      before(:each) do
        subject.config = { :secret_key => "ABCDEFGH12345" }
      end

      it "should return a formatted hash of Paybox fields" do
        OpenSSL::HMAC.should_receive(:hexdigest).and_return("abcdefg")
        h = subject.hash_form_fields_from({ :aaa => "aaa", :bbb => "bbb", :ccc => "ccc" })
        h.should be_a(Hash)
        h.keys.should include("PBX_AAA", "PBX_BBB", "PBX_CCC", "PBX_HASH", "PBX_TIME", "PBX_HMAC")

        h["PBX_HASH"].should == "SHA512"
        h["PBX_HMAC"].should == "ABCDEFG"
      end
    end
  end

  describe ".check_response?" do
    before(:each) do
      @paybox_response_params = "reference=id%204f3c497294b3026bfa000001&error=00001"
      @paybox_response_signature = "NuHxwhK%2BENWuXSXeqtGLa2Zezc7ttXvDvCuJa8h4iWXfDSkHCRAYgPazS1Fo%2Fn%2Bk8%2FksD5C6jP0%2Fgf9xQR0JndC0MPKvA6eDeDknEdAsQAriS%2Fk7vjazARAAY1h%2Bt4zROoMVWI8Ph5u%2Bcf6nKuShUOOBuoqyomVphJLKxVMfGtM%3D"
    end

    it "should verify Paybox response integrity" do
      Paybox::System::Base.should be_check_response(@paybox_response_params, @paybox_response_signature)
      Paybox::System::Base.should_not be_check_response(@paybox_response_params.upcase, @paybox_response_signature)
    end
  end
end
