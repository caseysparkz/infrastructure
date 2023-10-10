#!/usr/bin/env python3
# -*- coding:utf-8 -*-
# Author:   Casey Sparks
# Date:     October 05, 2023
# Description:
'''Python Lambda function for website contact page.'''

from logging import getLogger
from os import getenv
from typing import NoReturn
from boto3 import client

LOG = getLogger(__name__)                                                   # Instantiate logger.

def send_email(
    recipients: list[str],
    default_sender: str,
    sender_name: str,
    sender_email: str,
    subject: str,
    message: str,
        ) -> dict:
    '''
    Send an email via AWS SES.
        :param recipients:      Email recipient list.
        :param default_sender:  Email of the Lambda application (not the user).
        :param sender_name:     Email sender's name.
        :param sender_email:    Email sender's email address.
        :param subject:         Email subject line.
        :param message:         Email message body.
        :return:                Dict containing the SES response.
    '''
    assert isinstance(recipients, list), 'recipients must be list().'
    assert all(isinstance(item, str) for item in recipients), 'recipients must be list[str].'
    assert isinstance(sender_name, str), 'sender_name must be str().'
    assert isinstance(sender_email, str), 'sender_email must be str().'
    assert isinstance(subject, str), 'subject must be str().'
    assert isinstance(message, str), 'message must be str().'
    assert isinstance(default_sender, str), 'default_sender must be str().'

    ses_client = client('ses')
    response = ses_client.send_email(
        Destination={'ToAddresses': recipients},
        Message={
            'Body': {
                'Text': {
                    'Charset': 'UTF-8',
                    'Data': f'From: {sender_name}\nEmail: {sender_email}\nContent:\n{message}'
                }
            },
            'Subject': {
                'Charset': 'UTF-8',
                'Data': subject,
            }
        },
        Source=default_sender
    )

    LOG.debug(response)

    return response


def lambda_handler(
    event: dict,
    context: dict
        ) -> NoReturn:
    '''
    Default function for Lambda functions.
        :param event:   The Lamba event to handle.
        :param context: Context for said Lambda event.
    '''
    LOG.debug(f'Event: {event}')                                            # Log event.
    LOG.debug(f'Context: {context}')                                        # Log context.
    ses_response = send_email(                                              # Send email.
        recipients=[getenv('DEFAULT_RECIPIENT', 'EMPTY')],
        default_sender=getenv('DEFAULT_SENDER', 'EMPTY'),
        sender_name=event['body']['sender_name'] or 'EMPTY',
        sender_email=event['body']['sender_email'] or 'EMPTY',
        subject=event['body']['subject'] or 'EMPTY',
        message=event['body']['message'] or 'EMPTY'
    )

    return ses_response['body']['result']
