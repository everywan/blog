# Rabbitmq

参考: [AMQP](https://www.rabbitmq.com/amqp-0-9-1-reference.html)

## Publish
摘抄自 AMQP 标准

```Go
publish(short reserved-1, exchange-name exchange, shortstr routing-key, bit mandatory, bit immediate)
- bit mandatory

This flag tells the server how to react if the message cannot be routed to a queue. If this flag is set, the server will return an unroutable message with a Return method. If this flag is zero, the server silently drops the message.

The server SHOULD implement the mandatory flag.

- bit immediate

This flag tells the server how to react if the message cannot be routed to a queue consumer immediately. If this flag is set, the server will return an undeliverable message with a Return method. If this flag is zero, the server will queue the message, but with no guarantee that it will ever be consumed.

The server SHOULD implement the immediate flag.
```
