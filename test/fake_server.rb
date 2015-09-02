#!/usr/bin/env ruby
#
# This is a 'fake' MQTT-SN server to help with testing client implementations
#
# It behaves in the following ways:
#   * Responds to CONNECT with a successful CONACK
#   * Responds to PUBLISH by keeping a copy of the packet
#   * Responds to SUBSCRIBE with SUBACK and a PUBLISH to the topic
#   * Responds to PINGREQ with PINGRESP and keeps a count
#   * Responds to DISCONNECT with a DISCONNECT packet
#
# It has the following restrictions
#   * Doesn't deal with timeouts
#   * Only handles a single client
#

require 'logger'
require 'socket'
require 'mqtt'


class MQTT::SN::FakeServer
  attr_reader :address, :port
  attr_reader :thread
  attr_reader :packets_received
  attr_accessor :response_data
  attr_accessor :connack_return_code
  attr_accessor :logger

  # Create a new fake MQTT server
  #
  # If no port is given, bind to a random port number
  # If no bind address is given, bind to localhost
  def initialize(port=0, bind_address='127.0.0.1')
    @port = port
    @address = bind_address
    @response_data = 'Hello World'
    @connack_return_code = 0
    @packets_received = []
  end

  # Get the logger used by the server
  def logger
    @logger ||= Logger.new(STDOUT)
  end

  # Start the thread and open the socket that will process client connections
  def start
    @thread ||= Thread.new do
      Socket.udp_server_sockets(@address, @port) do |sockets|
        @address = sockets.first.local_address.ip_address
        @port = sockets.first.local_address.ip_port
        logger.info "Started a fake MQTT-SN server on #{@address}:#{@port}"
        Socket.udp_server_loop_on(sockets) do |data, client|
          response = process_packet(data)
          unless response.nil?
            response = [response] unless response.kind_of?(Enumerable)
            response.each do |packet|
              logger.debug "Replying with: #{packet.inspect}"
              client.reply(packet.to_s)
            end
          end
        end
      end
    end
  end

  # Stop the thread and close the socket
  def stop
    logger.info "Stopping fake MQTT-SN server"
    @thread.kill if @thread and @thread.alive?
    @thread = nil
  end

  # Start the server thread and wait for it to finish (possibly never)
  def run
    start
    begin
      @thread.join
    rescue Interrupt
      stop
    end
  end

  def wait_for_port_number
    while @port.to_i == 0
      Thread.pass
    end
    @port
  end

  def wait_for_packet(klass=nil, timeout=2)
    Timeout.timeout(timeout) do
      if block_given?
        @packets_received = []
        yield
      end
      loop do
        if klass.nil?
          unless @packets_received.empty?
            return @packets_received.last_packet
          end
        else
          @packets_received.each do |packet|
            return packet if packet.class == klass
          end
        end
        sleep(0.01)
      end
    end
  end

  protected

  def process_packet(data)
    packet = MQTT::SN::Packet.parse(data)
    @packets_received << packet
    logger.debug "Received: #{packet.inspect}"

    case packet
      when MQTT::SN::Packet::Connect
        if packet.clean_session
          MQTT::SN::Packet::Connack.new(:return_code => connack_return_code)
        else
          [
            MQTT::SN::Packet::Connack.new(:return_code => connack_return_code),
            MQTT::SN::Packet::Register.new(:topic_id => 5, :topic_name => 'old_topic'),
            MQTT::SN::Packet::Publish.new(:topic_id => 5, :data => 'old_msg')
          ]
        end
      when MQTT::SN::Packet::Publish
        nil
      when MQTT::SN::Packet::Pingreq
        MQTT::SN::Packet::Pingresp.new
      when MQTT::SN::Packet::Subscribe
        case packet.topic_id_type
          when :short
            topic_id = packet.topic_name
          when :predefined
            topic_id = packet.topic_id
          when :normal
            topic_id = 1
          else
            logger.warn "Unknown Topic Id Type: #{packet.topic_id_type}"
        end
        [
          MQTT::SN::Packet::Suback.new(
            :id => packet.id,
            :topic_id_type => packet.topic_id_type,
            :topic_id => topic_id,
            :return_code => 0
          ),
          MQTT::SN::Packet::Publish.new(
            :topic_id_type => packet.topic_id_type,
            :topic_id => topic_id,
            :data => @response_data
          )
        ]
      when MQTT::SN::Packet::Disconnect
        MQTT::SN::Packet::Disconnect.new
      when MQTT::SN::Packet::Register
        MQTT::SN::Packet::Regack.new(:id => packet.id, :topic_id => 1, :return_code => 0)
      when MQTT::SN::Packet::Regack
        nil
      else
        logger.warn "Unhandled packet type: #{packet.class}"
        nil
    end

    rescue MQTT::SN::ProtocolException => e
      logger.warn "Protocol error: #{e}"
      nil
  end
end

if __FILE__ == $0
  server = MQTT::SN::FakeServer.new(MQTT::SN::DEFAULT_PORT)
  server.logger.level = Logger::DEBUG
  server.run
end
