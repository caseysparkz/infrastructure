#!/usr/bin/env python3
# -*- coding:utf-8 -*-
# Author:       Casey Sparks
# Date:         October 05, 2023
# Description:
'''Python Lambda function for website contact page.'''

from json import dumps
from logging import getLogger, StreamHandler
from os import getenv
from textwrap import dedent
from urllib.parse import parse_qs
from boto3 import client

LOG = getLogger()

LOG.addHandler(StreamHandler())
LOG.setLevel(0)                                                                 # NOTSET


def send_email(
    email_obj: dict,
        ) -> dict:
    '''
    Send an email via AWS SES.
        :param email_obj:       Dict containing `REQUIRED_KEYS'.
        :return:                The SES client response.
    '''
    LOG.debug(f'Email object: {email_obj}')

    ses_client = client('ses')                                                  # Instantiate SES client.
    response = ses_client.send_email(                                           # Send email.
        Source=email_obj['default_sender'],
        Destination={'ToAddresses': [email_obj['default_recipient']]},
        Message={
            'Subject': {
                'Charset': 'UTF-8',
                'Data': email_obj['subject'],
                },
            'Body': {'Text': {
                'Charset': 'UTF-8',
                'Data': dedent(f'''
                    From: {email_obj['sender_name']}
                    Email: {email_obj['sender_email']}
                    Content: {email_obj['message']}
                    ''').strip('\n')
                }},
            },
        )

    LOG.debug(response)

    return response


def lambda_handler(
    event: dict,
    context: dict = None,
        ) -> dict:
    '''
    Default function for Lambda functions.
        :param event:   The Lamba event to handle.
        :param context: Context for said Lambda event.
        :return:        Dictionary containing the Lambda response.
    '''
    LOG.debug(f'Event: {event}')                                                # Log event.
    LOG.debug(f'Context: {context}')                                            # Log context.

    email_fields = parse_qs(event['body'])
    ses_response = send_email(                                                  # Send email.
        email_obj={                                                             # Email data.
            'default_sender': getenv('DEFAULT_SENDER'),
            'default_recipient': getenv('DEFAULT_RECIPIENT'),
            'sender_email': email_fields.get('sender_email')[0],
            'sender_name': email_fields.get('sender_name')[0],
            'subject': email_fields.get('subject')[0],
            'message': email_fields.get('message')[0],
            }
        )
    lambda_response = {
        'statusCode': 200,
        'headers': {'Content-Type': 'application/json'},
        'body': dumps({
            'Success': True,
            'MessageId': ses_response['MessageId']
            })
        }

    return lambda_response


if __name__ == '__main__':
    response_data = lambda_handler(                                            # Test Lambda function.
        event={                                                                 # Dummy data for event.
            'sender_email': 'test@test.com',
            'sender_name': 'John Doe',
            'subject': 'LAMBDA TEST',
            'message': 'Test email body.',
            }
        )

    LOG.info(response_data)
