#!/usr/bin/env python3
# -*- coding:utf-8 -*-
# Author:       Casey Sparks
# Date:         October 05, 2023
# Description:
'''Python Lambda function for website contact page.'''

from json import dumps, loads
from logging import getLogger, StreamHandler
from os import getenv
from textwrap import dedent
from boto3 import client

LOG = getLogger()

LOG.addHandler(StreamHandler())
LOG.setLevel(0)                                                                 # NOTSET


def send_email(
    data: dict,
        ) -> dict:
    '''
    Send an email via AWS SES.
        :param data:    Dict containing `REQUIRED_KEYS'.
        :return:        The SES client response.
    '''
    ses_client = client('ses')                                                  # Instantiate SES client.
    ses_response = ses_client.send_email(                                       # Send email.
        Source=getenv('DEFAULT_SENDER'),
        Destination={'ToAddresses': [getenv('DEFAULT_RECIPIENT')]},
        Message={
            'Subject': {'Charset': 'UTF-8', 'Data': 'Contact Form Response'},
            'Body': {'Text': {
                'Charset': 'UTF-8',
                'Data': dedent(f'''
                    From: {data['senderName']}
                    Email: {data['senderEmail']}
                    Content: {data['message']}
                    ''').strip('\n')
                }},
            },
        )

    LOG.debug(ses_response)

    return ses_response


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

    lambda_response = {
        'statusCode': 200,
        'headers': {'Content-Type': 'application/json'},
        'body': dumps({
            'Success': True,
            'SesResponse': send_email(loads(event['body'])),
            }),
        }

    LOG.debug(lambda_response)

    return lambda_response


if __name__ == '__main__':
    response_data = lambda_handler(event={'body': {                             # Test Lambda function.
        'sender_email': 'test@test.com',
        'sender_name': 'John Doe',
        'message': 'Test email body.',
        }})

    LOG.info(response_data)
