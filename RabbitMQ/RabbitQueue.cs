using Godot;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using System;
using System.Collections.Generic;
using System.Text;

public partial class RabbitQueue : Node{
	private const String USER = "incubator";
	private const String PASS = "incubator";
	private const String HOST = "localhost";
	private const int PORT = 5672;
	
	private ConnectionFactory factory = new ConnectionFactory();
	private IConnection connection;
	private IModel channel;
	
	private string exchangeName = "Incubator_AMQP";
	private string ROUTING_KEY_KF_PLANT_STATE = "incubator.record.kalmanfilter.plant.state";
	private string ROUTING_KEY_STATE = "incubator.record.driver.state";
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
		channel.QueueBind(queue: localQueue, exchange: exchangeName, routingKey: ROUTING_KEY_KF_PLANT_STATE);
		channel.QueueBind(queue: localQueue, exchange: exchangeName, routingKey: ROUTING_KEY_STATE);
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
