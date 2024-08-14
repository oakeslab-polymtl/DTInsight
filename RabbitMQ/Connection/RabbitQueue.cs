using Godot;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using System;
using System.Collections.Generic;
using System.Text;

public partial class RabbitQueue : Node{
	// Config ------------------------------------------------------------------
	private String user;
	private String pass;
	private String host;
	private int port;
	
	private string exchangeName;
	private string[] routingKeys;
	
	public void SetParameters(
		string user,
		string pass,
		string host,
		int port,
		string exchangeName,
		string routingKeys
	){
		this.user = user;
		this.pass = pass;
		this.host = host;
		this.port = port;
		this.exchangeName = exchangeName;
		this.routingKeys = routingKeys.Split('/');
	}
	//--------------------------------------------------------------------------
	private ConnectionFactory factory = new ConnectionFactory();
	private IConnection connection;
	private IModel channel;
	
	private string localQueue;
	private List<string> messages = new();
	
	[Signal]
	public delegate void UpdatedRabbitEventHandler(string message);

	public override void _Process(double delta) {
		for (int i = 0; i < messages.Count; i++) {
			EmitSignal(SignalName.UpdatedRabbit, messages[i]);
		}
		messages.Clear();
	}
	
	public bool ConnectToRabbitMQ() {
		factory.UserName = user;
		factory.Password = pass;
		factory.HostName = host;
		factory.Port = port;
	
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
	
	public void DisconnectRabbitMQ() {
		channel.Close();
		connection.Close();
	}
	
	private void ReceiveMessage() {
		var consumer = new EventingBasicConsumer(channel);

		consumer.Received += (model, ea) => {
			var body = ea.Body.ToArray();
			var message = Encoding.ASCII.GetString(body);
			messages.Add(message);
		};

		channel.BasicConsume(queue: localQueue, autoAck: true, consumer: consumer);
	}
}
