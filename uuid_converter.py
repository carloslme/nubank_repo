import uuid

import pandas as pd

integer_value = 1811589392032273152
uuid_string = str(uuid.UUID(int=integer_value))
print(uuid_string)