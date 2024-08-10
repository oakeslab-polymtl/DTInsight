using Godot;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using System;
using System.Collections.Generic;
using System.Text;

public partial class RabbitQueue : Node{
	// Config ------------------------------------------------------------------
	private const String USER = "incubator";
	private const String PASS = "incubator";
	private const String HOST = "localhost";
	private const int PORT = 5672;
	
	private string exchangeName = "Incubator_AMQP";
	private List<string> routingKeys = new List<string> {
		"incubator.update.closed_loop_controller.parameters",
		"incubator.record.kalmanfilter.plant.state",
		"incubator.record.driver.state",
		"incubator.record.driver.state",
		"incubator.hardware.gpio.fan.on",
		"incubator.record.#	",
		"incubator.hardware.gpio.heater.on",
		"incubator.update.kalmanfilter.4params",
		"incubator.mock.hw.box.G",
		"incubator.mock.hw.heater.on"
	};
	//--------------------------------------------------------------------------
	
	private ConnectionFactory factory = new ConnectionFactory();
	private IConnection connection;
	private IModel channel;
	
	private string localQueue;
	private List<string> messages = new();
	
	[Signal]
	public delegate void UpdatedRabbitEventHandler(string message);
	
	public override void _Ready(){
		ConnectToRabbitMQ();
	}

	public override void _Process(double delta) {
		for (int i = 0; i < messages.Count; i++) {
			EmitSignal(SignalName.UpdatedRabbit, messages[i]);
		}
		messages.Clear();
	}
	
	public bool ConnectToRabbitMQ() {
		factory.UserName = USER;
		factory.Password = PASS;
		factory.HostName = HOST;
		factory.Port = PORT;
	
		connection = factory.CreateConnection();
		channel = connection.CreateModel();
		
		
		localQueue = channel.QueueDeclare(autoDelete: true, exclusive: true);
		foreach (string routingKey in routingKeys)  {
			channel.QueueBind(queue: localQueue, exchange: exchangeName, routingKey: routingKey);
		}
		ReceiveMessage();
		
		if (!connection.IsOpen) {
			return false;
		}

		return true;
	}
	
	private void ReceiveMessage() {
		GD.Print("Waiting for messages");
		var consumer = new EventingBasicConsumer(channel);

		consumer.Received += (model, ea) => {
			var body = ea.Body.ToArray();
			var message = Encoding.ASCII.GetString(body);
			messages.Add(message);
		};

		channel.BasicConsume(queue: localQueue, autoAck: true, consumer: consumer);
	}
}
