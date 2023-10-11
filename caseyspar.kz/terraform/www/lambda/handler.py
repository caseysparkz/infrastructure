#!/usr/bin/env python3
# -*- coding:utf-8 -*-
# Author:   Casey Sparks
# Date:     October 05, 2023
# Description:
'''Python Lambda function for website contact page.'''

from logging import getLogger
from os import getenv
from textwrap import dedent
from boto3 import client

LOG = getLogger()                                                           # Instantiate logger.
REQUIRED_KEYS = {'sender_name', 'sender_email', 'subject', 'message'}

def send_email(
    email_obj: dict
        ) -> dict:
    '''
    Send an email via AWS SES.
        :param email_obj:   Dict containing email headers:
                            (default_recipient, default_sender, sender_name, sender_email, subject, message).
        :return:            Dict containing the SES response.
    '''
    assert isinstance(email_obj, dict), 'email_obj must be instance of dict().'
    assert REQUIRED_KEYS.intersection(email_obj.keys()) == REQUIRED_KEYS, 'email_obj missing keys.'
    assert all(isinstance(email_obj[value], str) for value in REQUIRED_KEYS), 'Invalid value type.'
    assert all(
        isinstance(email_obj[value], str) for value in ['default_recipient', 'default_sender']
    ), 'Invalid value type.'

    ses_client = client('ses')
    LOG.debug(response := ses_client.send_email(
        Destination={'ToAddresses': [email_obj['default_recipient']]},
        Message={
            'Body': {
                'Text': {
                    'Charset': 'UTF-8',
                    'Data': dedent(f'''
                        From: {email_obj['sender_name']}
                        Email: {email_obj['sender_email']}
                        Content: {email_obj['message']}
                    ''').strip('\n')
                }
            },
            'Subject': {
                'Charset': 'UTF-8',
                'Data': email_obj['subject'],
            }
        },
        Source=email_obj['default_sender']
    ))

    return response


def lambda_handler(
    event: dict,
    context: dict
        ) -> None:
    '''
    Default function for Lambda functions.
        :param event:   The Lamba event to handle.
        :param context: Context for said Lambda event.
    '''
    LOG.debug(f'Event: {event}')                                            # Log event.
    LOG.debug(f'Context: {context}')                                        # Log context.

    assert REQUIRED_KEYS.intersection(event['body'].keys()) == REQUIRED_KEYS, 'Event body missing keys.'

    ses_response = send_email({                                             # Send email.
        'default_recipient': getenv('DEFAULT_RECIPIENT', 'EMPTY'),
        'default_sender': getenv('DEFAULT_SENDER', 'EMPTY'),
        'sender_name': event['body']['sender_name'],
        'sender_email': event['body']['sender_email'],
        'subject': event['body']['subject'],
        'message': event['body']['message']
    })

    return ses_response['body']['result']
