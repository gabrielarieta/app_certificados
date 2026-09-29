const result = db.certificates.updateMany({}, {
  $rename: { emitedBy: 'issuedBy', emitedOn: 'issuedOn' },
});

printjson({ matched: result.matchedCount, modified: result.modifiedCount });