require 'spec_helper'
require 'electric_sheeps/log/console_logger'

describe ElectricSheeps::Log::ConsoleLogger do

    describe 'with a single logger' do

        before do
            @out = mock()
            @logger = subject.new(@out)
        end

        %w(info warn debug error fatal).each do |method|
            it "should redirect #{method} to out logger" do
                @out.expects(method).with('Hello World')
                @logger.send method, 'Hello World'
            end
        end

    end

    describe 'with distinct error and standard loggers' do

        before do
            @out = mock()
            @err = mock()
            @logger = subject.new(@out, @err)
        end

        %w(info warn debug).each do |method|
            it "should redirect #{method} to out logger" do
                @out.expects(method).with('Hello World')
                @err.expects(method).never
                @logger.send method, 'Hello World'
            end
        end

        %w(error fatal).each do |method|
            it "should redirect #{method} to err logger" do
                @err.expects(method).with('Goodbye Cruel World')
                @out.expects(method).never
                @logger.send method, 'Goodbye Cruel World'
            end
        end

    end
end