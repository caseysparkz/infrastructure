#!/usr/bin/env python3
# Author:       Casey Sparks
# Date:         October 05, 2023
# Description:
"""Python Lambda function for website contact page."""

import os
from json import dumps
from typing import TYPE_CHECKING
from unittest import mock

import boto3
import pytest
from moto import mock_aws

from .. import lambda_contact_form  # noqa:TID252

if TYPE_CHECKING:
    from collections.abc import Generator  # noqa:TC004

EVENT = {
    "body": dumps(
        {
            "sender_email": "test@test.com",
            "sender_name": "John Doe",
            "message": "Test email body.",
        }
    )
}


@pytest.fixture(autouse=True)
def set_environment(monkeypatch: pytest.MonkeyPatch) -> Generator[None]:
    """Set env vars expected by lambda handler."""
    with mock.patch.dict(os.environ, clear=True):
        monkeypatch.setenv("DEFAULT_SENDER", "testsender@test.com")
        monkeypatch.setenv("DEFAULT_RECIPIENT", "testrecipient@test.com")

        yield


@pytest.fixture(autouse=True)
def set_ses_client() -> Generator[None]:
    """Create a mock SES client."""
    with mock_aws():
        yield boto3.client("ses")


def test_send_email() -> None:
    """Send an email via AWS SES.

    Args:
        data:   Dict containing `REQUIRED_KEYS'.

    Returns:
                The SES client response.
    """
    assert lambda_contact_form.send_email(
        {
            "sender_email": "test@test.com",
            "sender_name": "John Doe",
            "message": "Test email body.",
        }
    )


def test_lambda_handler() -> None:
    """Default function for Lambda functions.

    Args:
        event:   The Lamba event to handle.
        context: Context for said Lambda event.

    Returns:
        Dictionary containing the Lambda response.
    """
    return
