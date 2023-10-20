#!/usr/bin/env python3
# -*- coding:utf-8 -*-
# Author:   Casey Sparks
# Date:     October 19, 2023
# Description:
'''
MODULE DOCSTRING
'''

from locale import setlocale, LC_ALL
from logging import getLogger, Formatter, RootLogger, StreamHandler
from requests import post

setlocale(LC_ALL, 'en_US.UTF-8')                                            # Set locale.


def enable_log(
    log_level: int = 10,
        ) -> RootLogger:
    '''
    Enable logging and handle outputs.
        :param log_level:   User-specified log level. Default NOTSET.
        :return:            Instantiated logger.RootLogger instance.
    '''
    assert 50 >= log_level >= 0, '`log_level` must be instance of int() between 0 and 50 (incl.).'

    formatter = Formatter(                                                  # Log message header format.
        '{asctime} {threadName:12} {levelname:8}: "{message}"',
        style='{'                                                           # Lazy string interpolation.
    )
    log_root = getLogger()                                                  # Root logger instance.
    log_console = StreamHandler()                                           # Log to screen.

    log_console.setFormatter(formatter)                                     # Set log stream format.
    log_root.addHandler(log_console)                                        # Log to screen.
    log_root.setLevel(log_level)                                            # User-specified log_level.

    return log_root


def send_email(
    endpoint: str,
    data: dict
        ):
    '''
    Test API gateway.
        :param endpoint:    The API gateway endpoint to test.
        :param data:        Data to encode in the body of the request.
        :return:            The request response.
    '''
    log.debug(response := post(
        endpoint,
        headers={'Content-Type': 'application/json'},
        data=data,
        timeout=3
    ))

    log.debug(response.reason)
    log.debug(response.text)

    return response


if __name__ == '__main__':
    log = enable_log()

    print(send_email(
        'https://rtz81j8ks3.execute-api.us-west-2.amazonaws.com/contact/contact_form',
        {
            'sender_name': 'casey',
            'sender_email': 'casey@caseyspar.ks',
            'subject': 'TEST',
            'message': 'TEST'
        },
    ))
