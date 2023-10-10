#!/usr/bin/env python3
# -*- coding:utf-8 -*-
# Author:   Casey Sparks
# Date:     October 05, 2023
# Description:
'''Python Lambda function for website contact page.'''

from logging import getLogger
from typing import NoReturn
from boto3 import client

LOG = getLogger(__name__)                                                   # Instantiate logger.

def send_email(
    recipients: list[str],
    name: str = "NULL",
    source: str = "NULL",
    subject: str = "NULL",
    message: str = "NULL"
        ) -> dict:
    '''
    Send an email via AWS SES.
        :param recipients:  Email recipient list.
        :param name:        Email sender's name.
        :param source:      Email sender's email address.
        :param subject:     Email subject line.
        :param message:     Email message body.
        :return:            Dict containing the SES response.
    '''
    ses_client = client('ses')                                              # Instantiate AWS SES client.
    body = f'From: {name}\nEmail: {source}\nContent:\n{message}'            # Format message body for email.
    response = ses_client.send_email(                                       # Send email to SES client.
        Destination={'ToAddresses': recipients},
        Message={
            'Body': {
                'Text': {
                    'Charset': 'UTF-8',
                    'Data': body
                }
            },
            'Subject': {
                'Charset': 'UTF-8',
                'Data': subject,
            }
        },
        Source=source
    )

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
    LOG.debug(f'Event: {event}\nContext: {context}')                        # Log event, context.
    ses_response = send_email(                                              # Send email to API.
        getenv('DEFAULT_RECIPIENT'),
        event['body']['name'] or getenv('DEFAULT_SENDER'), 
        event['body']['source'] or getenv('DEFAULT_EMAIL'),
        event['body']['subject'] or getenv('DEFAULT_SUBJECT'),
        event['body']['message'] or getenv('DEFAULT_MESSAGE')
    )

    return ses_response['body']['result']
