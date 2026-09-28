const duplicates = db.users
  .aggregate([
    {
      $project: {
        normalizedEmail: { $toLower: { $trim: { input: '$email' } } },
      },
    },
    {
      $group: {
        _id: '$normalizedEmail',
        userIds: { $push: '$_id' },
        count: { $sum: 1 },
      },
    },
    { $match: { count: { $gt: 1 } } },
  ])
  .toArray();

if (duplicates.length > 0) {
  print('Email normalization stopped because duplicate accounts were found:');
  printjson(duplicates);
  throw new Error('Resolve duplicate email accounts before running this script.');
}

const result = db.users.updateMany({}, [
  { $set: { email: { $toLower: { $trim: { input: '$email' } } } } },
]);

printjson({ matched: result.matchedCount, modified: result.modifiedCount });